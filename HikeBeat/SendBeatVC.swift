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
//import JSQCoreDataKit
import Alamofire

class SendBeatVC: UIViewController, UITextViewDelegate, UITextFieldDelegate, MFMessageComposeViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
/*
    Variables and Constants
*/
    
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
    }
    
    override func viewDidAppear(animated: Bool) {
        print("Original x", titleView.center.x)
        
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
                self.alert("It's send!", alertMessage: "Your Beat has been sent", actionTitle: "Awesome!")
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
        if titleTextField.text == "" && messageTextView.text == "" && currentImage == nil || self.activeJourney == nil && locationTuple.latitude != "" && locationTuple.longitude != "" {
            print("Something is not correct")
            // Give a warning that there is not text or no active journey.
            print("Something is missing")
        } else {
            var title: String? = nil
            var message: String? = nil
            var mediaData: String? = nil
            
            if titleTextField.text != "" {
                title = self.titleTextField.text
            }
            if messageTextView.text != "" {
                message = self.messageTextView.text
            }
            if currentImage != nil {
                let imageData = UIImageJPEGRepresentation(currentImage!, CGFloat(0.2))
                let base64String = imageData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
                mediaData = base64String
            }
            
            //            let locationTuple = self.getTimeAndLocation()
            print("Just Before Crash!")
            self.currentBeat = DataBeat(context: (self.stack?.mainContext)!, title: title, journeyId: activeJourney!.journeyId, message: message, latitude: locationTuple.latitude, longitude: locationTuple.longitude, timestamp: locationTuple.timestamp, mediaType: MediaType.image, mediaData: mediaData, mediaDataId: nil, messageId: nil, uploaded: false, journey: activeJourney!)
            print("Just After Crash!")
            self.sendBeat()
        }
    }
    
    func sendBeat() {
        if ((titleTextField.text!.characters.count + messageTextView.text.characters.count) > 0) {
            
            // Check if there is any network connection and send via the appropriate means.
            if Reachability.isConnectedToNetwork() {
                // TODO: send via alamofire
                let url = IPAddress + "journeys/" + (activeJourney?.journeyId)! + "/messages"
                print("url: ", url)
                
                // Parameters for the beat message
                let parameters = ["headline": currentBeat!.title!, "text": currentBeat!.message!, "lat": currentBeat!.latitude, "lng": currentBeat!.longitude, "timeCapture": currentBeat!.timestamp, "journeyId": (activeJourney?.journeyId)!]
                
                // Sending the beat message
                Alamofire.request(.POST, url, parameters: parameters, encoding: .JSON, headers: Headers).responseJSON { response in
                    print("The Response")
                    print(response.response?.statusCode)
                    
                    // if response is 200 OK from server go on.
                    if response.response?.statusCode == 200 {
                        print("The text was send")
                        
                        // Save the messageId to the currentBeat
                        let messageJson = JSON(response.result.value!)
                        self.currentBeat?.messageId = messageJson["_id"].stringValue
                        
                        // If the is an image in the currentBeat, send the image.
                        if self.currentBeat?.mediaData != nil {
                            // Send Image
                            /** Image Parameters including the image in base64 format. */
                            let imageParams = ["timeCapture": self.currentBeat!.timestamp, "journeyId": (self.activeJourney?.journeyId)!, "data": (self.currentBeat?.mediaData)!]
                            
                            /** The URL for the image*/
                            let imageUrl = IPAddress + "journeys/" + (self.activeJourney?.journeyId)! + "/images"
                            
                            // Sending the image.
                            Alamofire.request(.POST, imageUrl, parameters: imageParams, encoding: .JSON, headers: Headers).responseJSON { imageResponse in
                                // If everything is 200 OK from server save the imageId in currentBeat variable mediaDataId.
                                if imageResponse.response?.statusCode == 200 {
                                    let imageJson = JSON(imageResponse.result.value!)
                                    print(imageResponse)
                                    print("The image has been posted")
                                    
                                    // Set the imageId in currentBeat
                                    print("messageId: ", imageJson["_id"].stringValue)
                                    self.currentBeat?.mediaDataId = imageJson["_id"].stringValue
                                    
                                    // Set the uploaded variable to true as the image has been uplaoded.
                                    self.currentBeat?.uploaded = true
                                    saveContext(self.stack.mainContext)
                                } else if imageResponse.response?.statusCode == 400 {
                                    print("Error posting the image")
                                }
                            }
                        } else {
                            self.currentBeat?.uploaded = true
                            saveContext(self.stack.mainContext)
                        }
                        saveContext(self.stack.mainContext)
                    } else if response.response?.statusCode == 400 {
                        // Error occured
                        print("Error posting the message")
                    }
                    
                    // print(response)
                    // if the response is okay run:
                    // TODO: save the Beat
                    saveContext(self.stack.mainContext)
                    //                    self.saveCurrentBeat(uploaded)
                    self.setInitial(true)
                }
            } else {
                
                // This will send it via SMS, which is temporarily disabled.
                let messageText = self.genSMSMessageString(titleTextField.text!, message: messageTextView.text, journeyId: self.activeJourney!.journeyId)
                self.sendSMS(messageText)
                // The save and setInitial is done in the message methods as it knows whether it fails.
            }
            
            // TODO: save
            
        } else {
            //TODO: Set alert to tell user that there's no text.
        }
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

    func alert(alertTitle: String, alertMessage: String, actionTitle: String) {
        let alertController = UIAlertController(title: alertTitle, message:
            alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: actionTitle, style: UIAlertActionStyle.Default,handler: {(alert: UIAlertAction!) in
        self.setInitial(true)
        self.swipeView.setBack(true)
        }))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
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
    
    func getTimeAndLocation() -> (timestamp: String, latitude: String, longitude: String) {
        let currentDate = NSDate()
        let timeStamp = NSDateFormatter()
        timeStamp.dateFormat = "yyyyMMddHHmmss"
        let timeCapture = timeStamp.stringFromDate(currentDate)
        
        var longitude = ""
        var latitude = ""
        if let location = appDelegate.getLocation() {
            longitude = String(location.coordinate.longitude)
            latitude = String(location.coordinate.latitude)
        }
        return (timeCapture, latitude, longitude)
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
        let currentDate = NSDate()
        let timeStamp = NSDateFormatter()
        timeStamp.dateFormat = "yyyyMMddHHmmss"
        let timeCapture = timeStamp.stringFromDate(currentDate)
        
        var longitude = ""
        var latitude = ""
        if let location = appDelegate.getLocation() {
            longitude = String(location.coordinate.longitude)
            latitude = String(location.coordinate.latitude)
        }
        
        let smsMessageText = journeyId + " " + timeCapture + " " + latitude + " " + longitude + " " + title + "##" + message
        
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
            self.currentBeat?.uploaded = false
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
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        if picker.sourceType == .Camera {
            UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
        }
        //self.mediaImageView
        self.mediaImageView.image = image
        
//        // Finding ratio
//        let ratio = image.size.height / image.size.width
//        
//        // Getting current frame
//        let frame = self.mediaImageView.frame
//        
//        // Setting new frame
//        self.mediaImageView.frame = CGRectMake(frame.origin.x, frame.origin.y, 200, 200)
//        
//        var layer = self.mediaImageView.layer
//        layer.frame = CGRectMake(0, 0, 100, 100)
//        layer.backgroundColor = UIColor.whiteColor().CGColor
//        layer.opacity = 0.5
        
        
//        imageView.image = image
//        imageButton.imageView?.image = nil
//        imageButton.titleLabel?.text = ""
        currentImage = image
        dismissViewControllerAnimated(true, completion: nil)
    }
}

