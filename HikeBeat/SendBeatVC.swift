//
//  ViewController.swift
//  SlideoutBoxes
//
//  Created by Niklas Gundlev on 30/10/15.
//  Copyright © 2015 Niklas Gundlev. All rights reserved.
//

import UIKit
import MessageUI
import CoreData
import Alamofire
import CoreTelephony
import BrightFutures
import AVFoundation


class SendBeatVC: UIViewController, UITextViewDelegate, UITextFieldDelegate, MFMessageComposeViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
/*
    Variables and Constants
*/
    
    /* Media Veriables*/
    var currentMediaURL: NSURL?
    
    /* VideoRecorder variables*/
    var currentVideo: NSURL?
    
    /* AudioRecorder variables*/
    var recorder: AVAudioRecorder!
    var player:AVAudioPlayer!
    var meterTimer:NSTimer!
    var soundFileURL:NSURL!
    var audioHasBeenRecordedForThisBeat = false
    
    /**
    The amount translated in the set initial.
    */
    var translationLength:CGFloat = 0.0
    
    /**
     The amount the boxes has been moved in order to make room for the keyboard
     */
    var diff: CGFloat? = nil
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    var imagePicker = UIImagePickerController()
    var currentBeat: DataBeat? = nil
    var currentImage: UIImage? = nil
    var stack: CoreDataStack!
    var activeJourney: DataJourney?
    var firstTimeAppearing = true
    
    
/*
    IBOutlets and IBActions
*/
    
    /* AudioRecorder Outlets and actions*/
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    @IBAction func recordAudio(sender: AnyObject) {
        startRecordingAudio()
    }
    
    @IBAction func stopAudio(sender: AnyObject) {
        stopRecordingAudio()
    }
    
    @IBAction func playAudio(sender: AnyObject) {
        playAudio()
    }

    /* VideoRecorder Outlets and actions*/
    @IBAction func recordVideo(sender: AnyObject) {
        startRecordingVideo()
    }
    
    @IBAction func playVideo(sender: AnyObject) {
        playVideo()
    }

    
    /* All other outlets*/
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var mediaView: UIView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var mediaButton: UIButton!
    @IBOutlet weak var mediaLabel: UILabel!
    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var showMediaButton: UIButton!
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var swipeView: NSGSwipeView!
    
    @IBAction func addImage(sender: AnyObject) {
        self.chooseImage()
    }
    
    /**
    Function called by hidden buttons over middle labels to send out the drawer represented by the label.
     
     - parameters:
        - UIButton: The button who called the function.
     
     - returns: nil.
    */
    @IBAction func openDraw(sender: UIButton) {
        print(sender.restorationIdentifier)
        switch sender.restorationIdentifier! {
            case "titleButton": self.animateDrawToOpen(titleView)
            case "messageButton": self.animateDrawToOpen(messageView)
            case "showMediaButton": self.animateDrawToOpen(mediaView)
        default: print("None of the right buttons pressed")
        }
    }

    /**
    This function handles the pan of the slideout boxes and determines whether they should go to the open or clossed position.
    
     - parameters:
        - UIPanGestureRcognizer: The rocognizer attached to the box being panned.
     
     - returns: nil.
    */
    @IBAction func handlePan2(recognizer:UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self.view)
        
        if recognizer.state == UIGestureRecognizerState.Changed {
            /* If the translation takes the view beyond the point where you can grab it, just set it back. Might not be needed. UPDATE: has been commented out. */
            if (recognizer.view?.center.x)! + translation.x < translationLength {
            /* If the view tries to move further than allowed */
            } else if (recognizer.view?.center.x)! + translation.x > self.view.frame.width/2 {
                if recognizer.view?.tag == 1 {
                    titleTextField.alpha = 1
                    titleLabel.alpha = 1
                } else if recognizer.view?.tag == 2 {
                    messageLabel.alpha = 1
                    messageTextView.alpha = 1
                }  else if recognizer.view?.tag == 3 {
                    mediaLabel.alpha = 1
                    mediaButton.alpha = 1
                }
            /* When the view moves where it is allowed to. */
            } else {
                recognizer.view!.center = CGPoint(x:recognizer.view!.center.x + translation.x,
                    y:recognizer.view!.center.y)
                recognizer.setTranslation(CGPointZero, inView: self.view)
                if recognizer.view?.tag == 1 {
                    titleTextField.alpha = titleTextField.alpha + ((1/self.view.frame.width) * translation.x)
                    titleLabel.alpha = titleLabel.alpha + ((1/self.view.frame.width) * translation.x)
                } else if recognizer.view?.tag == 2 {
                    messageTextView.alpha = messageTextView.alpha + ((1/self.view.frame.width) * translation.x)
                    messageLabel.alpha = messageLabel.alpha + ((1/self.view.frame.width) * translation.x)
                } else if recognizer.view?.tag == 3 {
                    mediaButton.alpha = mediaButton.alpha + ((1/self.view.frame.width) * translation.x)
                    mediaLabel.alpha = mediaLabel.alpha + ((1/self.view.frame.width) * translation.x)
                }
            }
            
        } else if recognizer.state == UIGestureRecognizerState.Ended {
            let velocity = recognizer.velocityInView(self.view)
            
            /* If the view is beyond a point where or the velocity is so great that it should snap to the open position */
            if recognizer.view?.center.x > (self.view.frame.width/4) || velocity.x > 2000 {
                self.animateDrawToOpen(recognizer.view!)
                
            /* If the view is beyond a point where or the negative velocity is so great that it should snap to the closed position */
            } else if recognizer.view?.center.x < (self.view.frame.width/4) || velocity.x < -1500 {
                let duration = NSTimeInterval(0.2)
                
                UIView.animateWithDuration(duration, animations: {
                    recognizer.view?.center = CGPoint(x: (-self.view.frame.width/2) + 40 , y: (recognizer.view?.center.y)!)
                    if recognizer.view?.tag == 1 {
                        self.titleTextField.alpha = 0
                        self.titleLabel.alpha = 0
                        self.titleTextField.text = ""
                    } else if recognizer.view?.tag == 2 {
                        self.messageTextView.alpha = 0
                        self.messageLabel.alpha = 0
                        self.messageTextView.text = ""
                    } else if recognizer.view?.tag == 3 {
                        self.mediaLabel.alpha = 0
                        self.mediaButton.alpha = 0
                    }
                }, completion: { success in
                    if recognizer.view?.tag == 1 {
                        self.titleTextField.resignFirstResponder()
                    } else if recognizer.view?.tag == 2 {
                        self.messageTextView.resignFirstResponder()
                    }
                })
            }
        }
    }

    
/*
    Animation Helper Functions
*/

    /**
    Animates a box to the open position and sets all the input fields aplha.
     
     - parameters: 
        - UIView: The box-view to be opened.
    */
    func animateDrawToOpen(view: UIView) {
            let duration = NSTimeInterval(0.2)
            UIView.animateWithDuration(duration, delay: NSTimeInterval(), options: UIViewAnimationOptions.CurveEaseOut, animations: {
                if view.tag == 1 {
                    self.titleTextField.alpha = 1
                    self.titleLabel.alpha = 1
                } else if view.tag == 2 {
                    self.messageTextView.alpha = 1
                    self.messageLabel.alpha = 1
                } else if view.tag == 3 {
                    self.mediaLabel.alpha = 1
                    self.mediaButton.alpha = 1
                }
                view.center = CGPoint(x: self.view.center.x, y: view.center.y)
                }, completion: { success in
                    if view.tag == 1 {
                        self.titleTextField.becomeFirstResponder()
                    } else if view.tag == 2 {
                        self.messageTextView.becomeFirstResponder()
                    } else if view.tag == 3 {
                        self.titleTextField.resignFirstResponder()
                        self.messageTextView.resignFirstResponder()
                    }
            })
    }
    
    /**
     Setting the views out to the side.
     */
    func setInitial(animated: Bool) {
        let translationLength = -self.view.frame.width + 40
        self.translationLength = translationLength
        
        if !animated {
            titleTextField.alpha = 0
            titleLabel.alpha = 0
            messageLabel.alpha = 0
            messageTextView.alpha = 0
            mediaButton.alpha = 0
            mediaLabel.alpha = 0
            self.titleView.center = CGPoint(x: titleView.center.x + translationLength,
                y:self.titleView.center.y)
            self.messageView.center = CGPoint(x: messageView.center.x + translationLength,
                y:self.messageView.center.y)
            self.mediaView.center = CGPoint(x: mediaView.center.x + translationLength,
                y:self.mediaView.center.y)
        } else {
            animateViewsBackIfNeeded(titleView)
            animateViewsBackIfNeeded(messageView)
            animateViewsBackIfNeeded(mediaView)
        }
        
    }
    
    func animateViewsBackIfNeeded(view:UIView) {
        let duration = NSTimeInterval(0.1)
        print(view.center)
        print(CGPoint(x: view.center.x - self.translationLength,
            y:view.center.y))
        if view.center != CGPoint(x: (-self.view.frame.width/2) + 40 ,y: view.center.y) {
            print("The view should animate")
            UIView.animateWithDuration(duration, animations: {
                view.center = CGPoint(x: (-self.view.frame.width/2) + 40 ,y: view.center.y)
                if view.tag == 1 {
                    self.titleTextField.alpha = 0
                    self.titleLabel.alpha = 0
                    self.titleTextField.text = ""
                } else if view.tag == 2 {
                    self.messageTextView.alpha = 0
                    self.messageLabel.alpha = 0
                    self.messageTextView.text = ""
                } else if view.tag == 3 {
                    self.mediaLabel.alpha = 0
                    self.mediaButton.alpha = 0
                    self.mediaImageView.image = nil
                    self.currentImage = nil
                    self.currentMediaURL = nil
                    self.audioHasBeenRecordedForThisBeat = false
                    
                    
                }
            })
        }
    }
    
    
/*
    Life Cycle Functions
*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Setting the disable autolayout and set width for views */
        self.messageView.translatesAutoresizingMaskIntoConstraints = true
        self.titleView.translatesAutoresizingMaskIntoConstraints = true
        self.mediaView.translatesAutoresizingMaskIntoConstraints = true
        
        self.titleView.frame.size.width = self.view.frame.width
        self.messageView.frame.size.width = self.view.frame.width
        self.mediaView.frame.size.width = self.view.frame.width
        
        self.titleView.layer.shadowOpacity = 0.7
        self.titleView.layer.shadowRadius = 5
        self.messageView.layer.shadowOpacity = 0.7
        self.messageView.layer.shadowRadius = 5
        self.mediaView.layer.shadowOpacity = 0.7
        self.mediaView.layer.shadowRadius = 5
        self.titleView.layer.shadowOffset = CGSizeMake(0, 6)
        self.messageView.layer.shadowOffset = CGSizeMake(0, 6)
        self.mediaView.layer.shadowOffset = CGSizeMake(0, 6)
        
        // Set up the core data stack
        let model = CoreDataModel(name: ModelName, bundle: Bundle)
        let factory = CoreDataStackFactory(model: model)
        
        // TODO: make it possible to swipe to send only when stack is created and active journey set
        factory.createStackInBackground { (result: CoreDataStackResult) -> Void in
            switch result {
            case .Success(let s):
                print("Created stack!")
                self.stack = s
                self.getActiveJourney()
            case .Failure(let err):
                print("Failed creating the stack")
                print(err)
            }
        }
        
        setInitialAudio()
    }
    
    override func viewDidAppear(animated: Bool) {
        print("Original x", titleView.center.x)
        
        if self.stack != nil {
            // Set up the core data stack
            let model = CoreDataModel(name: ModelName, bundle: Bundle)
            let factory = CoreDataStackFactory(model: model)
            
            factory.createStackInBackground { (result: CoreDataStackResult) -> Void in
                switch result {
                case .Success(let s):
                    print("Created stack!")
                    self.stack = s
                    self.getActiveJourney()
                case .Failure(let err):
                    print("Failed creating the stack")
                    print(err)
                }
            }
        }
        
        // Get active journey if its not already there
        if self.stack != nil {
            print("Getting active journey")
            self.getActiveJourney()
        }
        
        if self.firstTimeAppearing {
            setInitial(false)
            
            // Setting up the NSGSwipeView
            swipeView.initializeViews()
            swipeView.title.text = "Send"
            swipeView.title.textColor = UIColor.whiteColor()
            swipeView.title.font = UIFont.boldSystemFontOfSize(17.0)
            swipeView.action = {
                //self.alert("It's send!", alertMessage: "Your Beat has been sent", actionTitle: "Awesome!")
                self.checkForCorrectInput()
            }
            self.firstTimeAppearing = false
        }
        
        // Set up notification on keyboard
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Remove notification on keyboard
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
/*
    Sending beat functions
*/
    
    func checkForCorrectInput() {
        let locationTuple = self.getTimeAndLocation()
        print(0.1)
        if locationTuple != nil {
            print(0.2)
            if ((titleTextField.text == "" && messageTextView.text == "" && currentImage == nil && currentVideo == nil) || self.activeJourney == nil || locationTuple!.latitude == "" || locationTuple!.longitude == "") {
                print(0.3)
                // Give a warning that there is not text or no active journey.
                print("Something is missing")
                print("Text: ", titleTextField.text == "" && messageTextView.text == "" && currentImage == nil && currentVideo == nil)
                print("Journey: ", self.activeJourney == nil)
                print("Lat: ", locationTuple!.latitude)
                print("Lng: ", locationTuple!.longitude)
                
            } else {
                
                print(0.4)
                var title: String? = nil
                var message: String? = nil
                var mediaData: String? = nil
                var orientation: String? = nil
                var mediaType: String? = nil
                print(0.5)
                if titleTextField.text != "" || titleTextField.text != " " || titleTextField.text != "  " || titleTextField.text != "   " {
                    title = self.titleTextField.text
                }
                print(0.6)
                if messageTextView.text != "" || titleTextField.text != " " || titleTextField.text != "  " || titleTextField.text != "   "{
                    message = self.messageTextView.text
                }
                print(0.7)
                if currentImage != nil {
                    //print(1)
                    let imageData = UIImageJPEGRepresentation(currentImage!, 0.5)
                    mediaType = MediaType.image
                    //print(2)
                    mediaData = saveMediaToDocs(imageData!, journeyId: (activeJourney?.journeyId)!, timestamp: locationTuple!.timestamp)
                    //print(3)
//                    let imageData = UIImageJPEGRepresentation(currentImage!, CGFloat(0.4))
////                    var orientation = currentImage?.imageOrientation
////                    print("Orientation: ", orientation?.rawValue)
//                    let base64String = imageData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
//                    mediaData = base64String
//                    
//                    // Gettiong orientation
//                    let rawOrientation = currentImage?.imageOrientation.rawValue
//                    switch rawOrientation! {
//                    case 0: orientation = "landscape"
//                    case 1: orientation = "landscape"
//                    case 2: orientation = "portrait"
//                    case 3: orientation = "portrait"
//                    default: print("No orientation")
//                    }
                } else if currentMediaURL != nil {
                    print(1)
                    mediaType = MediaType.video
                    print(2)
                    let videoData = NSData(contentsOfURL: currentMediaURL!)
                    mediaData = saveMediaToDocs(videoData!, journeyId: (activeJourney?.journeyId)!, timestamp: locationTuple!.timestamp)
                        if mediaData != nil {
                            self.removeMediaWithURL(currentMediaURL!)
                        }
                    print("mediaData: ", mediaData)
                } else if audioHasBeenRecordedForThisBeat {
                    mediaType = MediaType.audio
                    let pathToAudio = getPathToFileFromName("audio-temp.m4a")
                    let audioData = NSData(contentsOfURL: pathToAudio!)
                    mediaData = saveMediaToDocs(audioData!, journeyId: (activeJourney?.journeyId)!, timestamp: locationTuple!.timestamp)
                    self.recorder.deleteRecording()
                }
                


                
                //            let locationTuple = self.getTimeAndLocation()
                print("Just Before Crash!")
                self.currentBeat = DataBeat(context: (self.stack?.mainContext)!, title: title, journeyId: activeJourney!.journeyId, message: message, latitude: locationTuple!.latitude, longitude: locationTuple!.longitude, timestamp: locationTuple!.timestamp, mediaType: mediaType, mediaData: mediaData, mediaDataId: nil, messageId: nil, mediaUploaded: false, messageUploaded: false, orientation:  orientation, journey: activeJourney!)
                print("Just After Crash!")
                self.sendBeat()
            }
        } else {
            
        }
    }
    
    func sendBeat() {
        
        if ((titleTextField.text!.characters.count + messageTextView.text.characters.count) > 0) {
            
            // Check if there is any network connection and send via the appropriate means.
            if SimpleReachability.isConnectedToNetwork() {
                // TODO: send via alamofire
                let url = IPAddress + "journeys/" + (activeJourney?.journeyId)! + "/messages"
                print("url: ", url)
                
                // Parameters for the beat message
                print("activeJourneyId", (activeJourney?.journeyId)!)
                print(currentBeat?.latitude)
                print(currentBeat?.longitude)
                print(currentBeat?.title)
                print(currentBeat?.message)
                print(currentBeat?.timestamp)
                var localTitle = ""
                var localMessage = ""
                if currentBeat!.message != nil {
                    localMessage = currentBeat!.message!
                }
                if currentBeat!.title != nil {
                    localTitle = currentBeat!.title!
                }
                
                let parameters = ["headline": localTitle, "text": localMessage, "lat": currentBeat!.latitude, "lng": currentBeat!.longitude, "timeCapture": currentBeat!.timestamp]
                print(1)
                // Sending the beat message
                Alamofire.request(.POST, url, parameters: parameters, encoding: .JSON, headers: Headers).responseJSON { response in
                    print("The Response")
                    print(response.response?.statusCode)
                    print(response)
                    
                    // if response is 200 OK from server go on.
                    if response.response?.statusCode == 200 {
                        print("The text was send")
                        self.currentBeat?.messageUploaded = true
                        
                        // Save the messageId to the currentBeat
                        let rawMessageJson = JSON(response.result.value!)
                        let messageJson = rawMessageJson["data"][0]
                        self.currentBeat?.messageId = messageJson["_id"].stringValue
                        
                        // If the is an image in the currentBeat, send the image.
                        if self.currentBeat?.mediaData != nil {
                            print("There is an image or video")
                            // Send Image
                            
//                            if self.currentBeat?.mediaType == MediaType.image {
//                                // Find image orientation
//                                /** Image Parameters including the image in base64 format. */
//                                let imageParams: [String: AnyObject] = ["timeCapture": self.currentBeat!.timestamp, "data": (self.currentBeat?.mediaData)!, "type": (self.currentBeat?.mediaType!)!]
//                                //, "orientation": (self.currentBeat?.orientation)!
//                                
//                                /** The URL for the image*/
//                                let imageUrl = IPAddress + "journeys/" + (self.activeJourney?.journeyId)! + "/media"
//                                
//                                // Sending the image.
//                                Alamofire.request(.POST, imageUrl, parameters: imageParams, encoding: .JSON, headers: Headers).responseJSON { imageResponse in
//                                    // If everything is 200 OK from server save the imageId in currentBeat variable mediaDataId.
//                                    if imageResponse.response?.statusCode == 200 {
//                                        let rawImageJson = JSON(imageResponse.result.value!)
//                                        let imageJson = rawImageJson["data"][0]
//                                        print(imageResponse)
//                                        print("The image has been posted")
//                                        
//                                        // Set the imageId in currentBeat
//                                        print("messageId: ", imageJson["_id"].stringValue)
//                                        self.currentBeat?.mediaDataId = imageJson["_id"].stringValue
//                                        
//                                        // Set the uploaded variable to true as the image has been uplaoded.
//                                        self.currentBeat?.mediaUploaded = true
//                                        saveContext(self.stack.mainContext)
//                                    } else {
//                                        print("Error posting the image")
//                                        self.currentBeat?.mediaUploaded = false
//                                        saveContext(self.stack.mainContext)
//                                    }
//                                    
//                                    self.setInitial(true)
//                                    self.swipeView.setBack(true)
//                                }
//                            } else 
                            //if self.currentBeat?.mediaType == MediaType.video || self.currentBeat?.mediaType == MediaType.image {
                                let filePath = self.getPathToFileFromName((self.currentBeat?.mediaData)!)
                                if filePath != nil {
                                    let urlMedia = IPAddress + "journeys/" + (self.activeJourney?.journeyId)! + "/media"
                                    print(urlMedia)
                                    
                                    var customHeader = Headers
                                    
                                    customHeader["x-hikebeat-timecapture"] = self.currentBeat?.timestamp
                                    customHeader["x-hikebeat-type"] = self.currentBeat?.mediaType!

                                    Alamofire.upload(.POST, urlMedia,headers: customHeader, file: filePath!).responseJSON { mediaResponse in
                                        print("This is the media response: ", mediaResponse)
                                        
                                        // If everything is 200 OK from server save the imageId in currentBeat variable mediaDataId.
                                        if mediaResponse.response?.statusCode == 200 {
                                            let rawImageJson = JSON(mediaResponse.result.value!)
                                            let mediaJson = rawImageJson["data"][0]
                                            print(mediaResponse)
                                            print("The image has been posted")
    
                                            // Set the imageId in currentBeat
                                            print("messageId: ", mediaJson["_id"].stringValue)
                                            self.currentBeat?.mediaDataId = mediaJson["_id"].stringValue
    
                                            // Set the uploaded variable to true as the image has been uplaoded.
                                            self.currentBeat?.mediaUploaded = true
                                            saveContext(self.stack.mainContext)
                                        } else {
                                            print("Error posting the image")
                                            self.currentBeat?.mediaUploaded = false
                                            saveContext(self.stack.mainContext)
                                        }
                                        
                                        self.setInitial(true)
                                        self.swipeView.setBack(true)
                                        
                                    }
                                }
                            //}

                        } else {
                            print("There's no image")
                            self.currentBeat?.mediaUploaded = true
                            saveContext(self.stack.mainContext)
                            self.setInitial(true)
                            self.swipeView.setBack(true)
                        }
                        
                        //Likely not usefull call to saveContext -> Test it!!
                        saveContext(self.stack.mainContext)
                    } else {
                        // Error occured
                        print("Error posting the message")
                        alert("Problem sending", alertMessage: "Some error has occured when trying to send, it will be saved and syncronized later", vc: self, actions:
                            (title: "Ok",
                                style: UIAlertActionStyle.Cancel,
                                function: {}))
                        self.currentBeat?.mediaUploaded = false
                        self.currentBeat?.messageUploaded = false
                        saveContext(self.stack.mainContext)
                    }
                    
                    // print(response)
                    // if the response is okay run:
                    // TODO: save the Beat
                    saveContext(self.stack.mainContext)
                    //                    self.saveCurrentBeat(uploaded)
                    //self.setInitial(true)
                }
//                self.setInitial(true)
//                self.swipeView.setBack(true)
            } else {
                
                // This will send it via SMS.
                print("Not reachable, should send sms")
                let messageText = self.genSMSMessageString(titleTextField.text!, message: messageTextView.text, journeyId: self.activeJourney!.journeyId)
                self.sendSMS(messageText)
                // The save and setInitial is done in the message methods as it knows whether it fails.
            }
            
            // TODO: save
            
        } else {
            //TODO: Set alert to tell user that there's no text.
        }
    }
    
    
    // this function creates the required URLRequestConvertible and NSData we need to use Alamofire.upload
    func urlRequestWithComponents(urlString:String, parameters:Dictionary<String, String>, imageData:NSData) -> (URLRequestConvertible, NSData) {
        
        // create url request to send
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        let boundaryConstant = "myRandomBoundary12345";
        let contentType = "multipart/form-data;boundary="+boundaryConstant
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        
        
        // create upload data to send
        let uploadData = NSMutableData()
        
        // add image
        uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Disposition: form-data; name=\"file\"; filename=\"file.png\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Type: image/png\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData(imageData)
        
        // add parameters
        for (key, value) in parameters {
            uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        uploadData.appendData("\r\n--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        
        
        // return URLRequestConvertible and NSData
        return (Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData)
    }
    

/*
    Keyboard Functions
*/
    
    func keyboardWillShow(notification: NSNotification) {
        var currentView = UIView()
        if titleTextField.isFirstResponder() {
            print("mediaTextView")
            currentView = self.titleView
        } else if messageTextView.isFirstResponder() {
            print("messageTextView")
            currentView = self.messageView
        }
        
        let userInfo = notification.userInfo!
        let keyboardSize: CGSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue().size
        var rect: CGRect = self.view.frame
        rect.size.height -= keyboardSize.height

        if !rect.contains(CGPoint(x: currentView.center.x, y: currentView.center.y + currentView.frame.height/2)) {
            print("Diff was set")
            if self.diff != nil {
                titleView.center = CGPoint(x: titleView.center.x, y: titleView.center.y - self.diff!)
                messageView.center = CGPoint(x: messageView.center.x, y: messageView.center.y - self.diff!)
                mediaView.center = CGPoint(x: mediaView.center.x, y: mediaView.center.y - self.diff!)
                self.diff = self.diff! + (currentView.center.y + currentView.frame.height/2) - rect.height
            } else {
                self.diff = (currentView.center.y + currentView.frame.height/2) - rect.height
                titleView.center = CGPoint(x: titleView.center.x, y: titleView.center.y - self.diff!)
                messageView.center = CGPoint(x: messageView.center.x, y: messageView.center.y - self.diff!)
                mediaView.center = CGPoint(x: mediaView.center.x, y: mediaView.center.y - self.diff!)
            }

        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        print("Keyboard has hidden")
        
        if self.diff != nil {
            print("Diff is not nil and will set boxes back")
            titleView.center = CGPoint(x: titleView.center.x, y: titleView.center.y + self.diff!)
            messageView.center = CGPoint(x: messageView.center.x, y: messageView.center.y + self.diff!)
            mediaView.center = CGPoint(x: mediaView.center.x, y: mediaView.center.y + self.diff!)
            self.diff = nil
        }
    }
    
/*
    TextView Functions
*/
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        
        let  char = text.cStringUsingEncoding(NSUTF8StringEncoding)!
        let isBackSpace = strcmp(char, "\\b")
        if (isBackSpace == -92) {
            return true
        } else if ((self.titleTextField.text!.characters.count + self.messageTextView.text.characters.count) > 121) {
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
/*
    Utility Functions
*/

//    func alert(alertTitle: String, alertMessage: String, actionTitle: String) {
//        let alertController = UIAlertController(title: alertTitle, message:
//            alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
//        alertController.addAction(UIAlertAction(title: actionTitle, style: UIAlertActionStyle.Default,handler: {(alert: UIAlertAction!) in
//        self.setInitial(true)
//        self.swipeView.setBack(true)
//        }))
//        
//        self.presentViewController(alertController, animated: true, completion: nil)
//    }
    
    func getActiveJourney() {
        let e = entity(name: EntityType.DataJourney, context: self.stack.mainContext)
        let activeJourney = FetchRequest<DataJourney>(entity: e)
        let firstDesc = NSSortDescriptor(key: "activeString", ascending: true)
        activeJourney.predicate = NSPredicate(format: "active == %@", true)
        activeJourney.sortDescriptors = [firstDesc]
        
        do {
            let result = try fetch(request: activeJourney, inContext: stack.mainContext)
            if result.count != 0 {
                print("The new journey has been successfully fetched")
                self.activeJourney = result[0]
            } else {
                print("There is no active journey")
            }
            
        } catch {
            print("failed in fetching data")
            assertionFailure("Failed to fetch: \(error)")
        }
    }
    
    
    /**
    function to get the timestamp and location.
     
     - parameters:
        - nil
     
     - returns: Bundle with 4 strings: timestamp, latitude, longitude, altitude.
    */
    func getTimeAndLocation() -> (timestamp: String, latitude: String, longitude: String, altitude: String)? {
        let t = String(NSDate().timeIntervalSince1970)
        let e = t.rangeOfString(".")
        let timestamp = t.substringToIndex((e?.startIndex)!)
//        let timeStamp = NSDateFormatter()
//        timeStamp.dateFormat = "yyyyMMddHHmmss"
//        let timeCapture = timeStamp.stringFromDate(currentDate)
        
        var longitude = ""
        var latitude = ""
        var altitude = ""
        if let location = appDelegate.getLocation() {
            let gpsCheck = userDefaults.boolForKey("GPS-check")
            if gpsCheck {
                // Now performing gps check
                print("now performing gps check")
                if location.verticalAccuracy > 150 || location.horizontalAccuracy > 150 {
                    alert("Poor GPS signal", alertMessage: "The GPS accuracy is too poor as it is within 150m, wait until it is better.", vc: self, actions:
                        (title: "Ok",
                            style: UIAlertActionStyle.Cancel,
                            function: {}
                        ))
                    return nil
                } else {
                    print("GPS is fine")
                    print("Vertical Accuracy: ", location.verticalAccuracy)
                    print("Horizontal Accuracy: ", location.horizontalAccuracy)
                    longitude = String(location.coordinate.longitude)
                    latitude = String(location.coordinate.latitude)
                    altitude = String(location.altitude)
                    return (timestamp, latitude, longitude, altitude)
                }
            } else {
                print("Not performing gps check")
                longitude = String(location.coordinate.longitude)
                latitude = String(location.coordinate.latitude)
                altitude = String(location.altitude)
                return (timestamp, latitude, longitude, altitude)
            }
        } else {
            print("did not get the location for app delegate")
            return nil
        }
    }
    
    
    /**
     Generates a string for the text messagebased on the input.
     
     - parameters:
     - String: title
     - String: message
     - String: journeyId
     
     - returns: String formatted for SMS.
     */
    func genSMSMessageString(title: String, message: String, journeyId: String) -> String {
        
        // Get current timestamp
//        let currentDate = NSDate()
//        let timeStamp = NSDateFormatter()
//        timeStamp.dateFormat = "yyyyMMddHHmmss"
//        let timeCapture = timeStamp.stringFromDate(currentDate)
//        
//        var longitude = ""
//        var latitude = ""
//        if let location = appDelegate.getLocation() {
//            longitude = String(location.coordinate.longitude)
//            latitude = String(location.coordinate.latitude)
//        }
//        let time = hex(Double((self.currentBeat?.timestamp)!)!)
//        let smsMessageText = journeyId + " " + timeCapture + " " + latitude + " " + longitude + " " + title + "##" + message
        
        print("timestamp deci: ", self.currentBeat?.timestamp)
        print("timestamp hex: ", hex(Double((self.currentBeat?.timestamp)!)!))
        let smsMessageText = journeyId + " " + hex(Double((self.currentBeat?.timestamp)!)!) + " " + hex(Double((self.currentBeat?.latitude)!)!) + " " + hex(Double((self.currentBeat?.longitude)!)!) + " " + title + "##" + message
        
        return smsMessageText
    }
    
    
/*
    SMS functions
*/
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        
        switch (result.rawValue) {
        case MessageComposeResultCancelled.rawValue:
            print("Message Cancelled")
            self.dismissViewControllerAnimated(true, completion: nil)
        case MessageComposeResultFailed.rawValue:
            print("Message Failed")
            
            self.dismissViewControllerAnimated(true, completion: nil)
        case MessageComposeResultSent.rawValue:
            print("Message Sent")
            
            /* Save the Beat and setInitial*/
            if currentBeat?.mediaData != nil {
                print("SMS function: There is an image")
                self.currentBeat?.mediaUploaded = false
            } else {
                print("SMS function: There is no image")
                self.currentBeat?.mediaUploaded = true
            }
            self.currentBeat?.messageUploaded = true
            saveContext(stack.mainContext)
            self.setInitial(true)
            self.swipeView.setBack(true)
            self.dismissViewControllerAnimated(true, completion: nil)
        default:
            break;
        }
    }
    
    /**
     This method starts a text message view controller with the settings specified.
     
     - parameters:
     - String: The text body composed of title, text, lattitude, longitude, timestamp and journeyId.
     - returns: Nothing as we have a seperate method to handle the result:
     `messageComposeViewController(controller:, didFinishWithResult result:)`.
     
     */
    func sendSMS(smsBody: String) {
        
        print("In sms function")
        let messageVC = MFMessageComposeViewController()
        if MFMessageComposeViewController.canSendText() {
            messageVC.body = smsBody
            messageVC.recipients = [phoneNumber]
            messageVC.messageComposeDelegate = self;
            
            self.presentViewController(messageVC, animated: false, completion: nil)
        }
    }
    
    
/*
    Camera functions
*/
    
    /**
    Presents an alertview actionsheet with the options to choose camera or photo library. Opens the chosen resource with UIImagePickerController
    */
    func chooseImage() {
        let optionsMenu = UIAlertController(title: "Choose resource", message: nil, preferredStyle: .ActionSheet)
        let cameraRoll = UIAlertAction(title: "Photo library", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Camera Roll")
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
                print("Button capture")
                
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .PhotoLibrary;
                self.imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureMode.Photo
                self.imagePicker.allowsEditing = false
                
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }
        })
        let takePhoto = UIAlertAction(title: "Camera", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Take Photo")
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
                print("Button capture")
                
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .Camera
                //self.imagePicker.mediaTypes = [kUTTypeImage as String]
                //self.imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureMode.Photo
                self.imagePicker.allowsEditing = false
                
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }
        })
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Take Photo")
        })
        
        optionsMenu.addAction(cameraRoll)
        optionsMenu.addAction(takePhoto)
        optionsMenu.addAction(cancel)
        
        self.presentViewController(optionsMenu, animated: true, completion: nil)
    }
    
    // NOT IN USE!!!
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
//       print("The image Function is run")
////        let rotatedImage = UIImage(CGImage: image.CGImage!, scale: 1.0, orientation: UIImageOrientation.Right)
//        if picker.sourceType == .Camera {
//            
////            var rotatedImage = UIImage(CGImage: image.CGImage!, scale: 1.0, orientation: .DownMirrored)
//            
//            UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
//            
//        }
//        //self.mediaImageView
//        self.mediaImageView.image = image
//        
////        // Finding ratio
////        let ratio = image.size.height / image.size.width
////        
////        // Getting current frame
////        let frame = self.mediaImageView.frame
////        
////        // Setting new frame
////        self.mediaImageView.frame = CGRectMake(frame.origin.x, frame.origin.y, 200, 200)
////        
////        var layer = self.mediaImageView.layer
////        layer.frame = CGRectMake(0, 0, 100, 100)
////        layer.backgroundColor = UIColor.whiteColor().CGColor
////        layer.opacity = 0.5
//        
//        
////        imageView.image = image
////        imageButton.imageView?.image = nil
////        imageButton.titleLabel?.text = ""
//        currentImage = image
//        dismissViewControllerAnimated(true, completion: nil)
//    }
}

