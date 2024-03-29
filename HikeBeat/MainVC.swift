//
//  MainVC.swift
//  HikeBeat
//
//  Created by Niklas Gundlev on 27/08/15.
//  Copyright © 2015 Niklas Gundlev. All rights reserved.
//

import UIKit
import MessageUI
import CoreData
//import JSQCoreDataKit
import Alamofire

class MainVC: UIViewController, MFMessageComposeViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
//    let alertView = SCLAlertView()
//    //alertView.addButton("First Button", target:self, selector:Selector("firstButton"))
//    alertView.showCloseButton = false
//    alertView.addButton("First Button") {
//    print("First button tapped")
//    }
//    alertView.showSuccess("Button View", subTitle: "This alert view has buttons")


/*
    Variables and Constants
*/
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var imagePicker = UIImagePickerController()
    var currentBeat: Beat? = nil
//    var currentBeat: DataBeat? = nil
    var currentImage: UIImage? = nil
    
    
/*
    IBOutlets and IBActions from the storyboard
*/
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var latitude: UILabel!
    @IBOutlet weak var longitude: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var titleBeatBox: UILabel!
    @IBOutlet weak var messageBeatBox: UILabel!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var showBeatButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewBeatBox: UIImageView!
    @IBOutlet weak var sendBeatButton: UIButton!
    
    /** The view showing the written Beat and asking the user to send it.*/
    @IBOutlet weak var beatView: UIView!
    
    
    /** Button indicating the user wants to send only a text update.*/
    @IBAction func sendBeat(sender: UIButton) {
        
        if ((titleTextView.text.characters.count + messageTextView.text.characters.count) > 0) {
            
            // Check if there is any network connection and send via the appropriate means.
            if Reachability.isConnectedToNetwork() {
                // TODO: send via alamofire
                let url = IPAddress + "journeys/" + userDefaults.stringForKey("activeJourneyId")! + "/messages"
                
                let parameters = ["title": currentBeat!.title!, "text": currentBeat!.message!, "lat": currentBeat!.latitude, "lng": currentBeat!.longitude, "timeCapture": currentBeat!.timestamp, "journeyId": userDefaults.stringForKey("activeJourneyId")!]
                
                Alamofire.request(.POST, url, parameters: parameters).authenticate(user: APIname, password: APIPass).responseJSON { response in
                    
                   // print(response)
                    let uploaded = true
                    // if the response is okay run:
                    // TODO: save the Beat
                    self.saveCurrentBeat(uploaded)
                    self.clearTextAndImage()
                    self.setInitialState(true)
                }
            } else {
                let messageText = self.genSMSMessageString(titleTextView.text, message: messageTextView.text, journeyId: self.userDefaults.objectForKey("activeJourneyId") as! String)
                self.sendSMS(messageText)
                // The save and setInitial is done in the message methods as it knows whether it fails.
            }
            
            // TODO: save
            
        } else {
            //TODO: Set alert to tell user that there's no text.
        }
    }
    
    /** Button indication that the user wants to take a picture to be uploaded if and when there has been established an internet connection.*/
    @IBAction func sendImage(sender: AnyObject) {
        chooseImage()
    }
    
    /** Button creating a Beat from the information and showing the beatView.*/
    @IBAction func showBeat(sender: AnyObject) {
        
        if titleTextView.text == "" && messageTextView.text == "" && currentImage == nil {

        } else {
            self.currentBeat = Beat(appDelegate: appDelegate)
            if titleTextView.text != "" {
                self.currentBeat?.title = self.titleTextView.text
            }
            if messageTextView.text != "" {
                self.currentBeat?.message = self.messageTextView.text
            }
            if currentImage != nil {
                let imageData = UIImageJPEGRepresentation(currentImage!, CGFloat(0.2))
                let base64String = imageData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
                self.currentBeat?.image = base64String
            }
            self.getBeatBox()
        }

    }
    
    /** Button in the text message view indicating that the user wishes to add an image to the text.*/
    @IBAction func addImage(sender: AnyObject) {
        chooseImage()
    }
    
    /** The cancel button removes the text message view.*/
    @IBAction func cancelButton(sender: AnyObject) {
        self.setInitialState(true)
    }
    
    
/*
    UIViewController life-cycle functions
*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setInitialState(false)
        
        self.titleTextView.layer.cornerRadius = 5
        self.titleTextView.layer.borderWidth = 1;
        self.titleTextView.layer.borderColor = UIColor.whiteColor().CGColor
        
        self.messageTextView.layer.cornerRadius = 5
        self.messageTextView.layer.borderWidth = 1;
        self.messageTextView.layer.borderColor = UIColor.whiteColor().CGColor
        
//        imageButton.layer.cornerRadius = imageButton.frame.height/2;
//        imageButton.layer.borderWidth = 1;
//        imageButton.layer.borderColor = UIColor.whiteColor().CGColor
        imageButton.imageView?.contentMode = .ScaleAspectFit
        
        showBeatButton.layer.cornerRadius = 5;
        showBeatButton.layer.borderWidth = 1;
        showBeatButton.layer.borderColor = UIColor.whiteColor().CGColor
        
        sendBeatButton.layer.cornerRadius = 5;
        sendBeatButton.layer.borderWidth = 1;
        sendBeatButton.layer.borderColor = UIColor.blackColor().CGColor
        
//        bigGreenBox.layer.cornerRadius = 5
//        bigGreenBox.layer.borderWidth = 3
//        bigGreenBox.layer.borderColor = UIColor.greenColor().CGColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
/*
    Animations
*/
    
    /**
    This method sets the initial state of the text message view.
    
    - parameters:
        - Bool: Indicates whether or not the animation should take any time.
    
    - returns: The function returns nothing after having set everything up.
    */
    func setInitialState(withDuration: Bool) {
        
        var duration = NSTimeInterval(0)
        if withDuration {
            duration = NSTimeInterval(0.5)
        }
        
        let translation: CGAffineTransform! = CGAffineTransformMakeTranslation(0, -self.view.frame.height)
        UIView.animateWithDuration(duration, animations: {
        
            self.beatView.transform = translation
        })
    }
    
    /**
    Runs animation to get the message view back on the screen
    
    - parameters:
        - nil:
    - returns: Nothing
    */
    func getBeatBox() {
        
        if Reachability.isConnectedToNetwork() {
            // TODO: Set icon for cennected.
        }
        
        latitude.text = (currentBeat?.latitude)!
        longitude.text = (currentBeat?.longitude)!
//        time.text = (currentBeat?.timestamp)!
        titleBeatBox.text = currentBeat?.title
        messageBeatBox.text = currentBeat?.message
        imageViewBeatBox.image = currentBeat?.createImageFromBase64()
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let date = formatter.dateFromString((currentBeat?.timestamp)!)
        
        let toFormatter = NSDateFormatter()
        toFormatter.dateFormat = "d. MMM yyyy @ HH:mm:ss"
        let timeString = toFormatter.stringFromDate(date!)
        
        time.text = timeString
        
        let translation: CGAffineTransform! = CGAffineTransformMakeTranslation(0, 0)
        UIView.animateWithDuration(NSTimeInterval(0.5), animations: {
            
            self.beatView.transform = translation
        })
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
            self.saveCurrentBeat(false)
            self.clearTextAndImage()
            self.setInitialState(true)
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
    TextView functions
*/
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    func textViewDidChange(textView: UITextView) {
        
        progressBar.setProgress(Float(titleTextView.text.characters.count + messageTextView.text.characters.count) / 122, animated: true)
    }
    
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        
        let  char = text.cStringUsingEncoding(NSUTF8StringEncoding)!
        let isBackSpace = strcmp(char, "\\b")
        if (isBackSpace == -92) {
            return true
        } else if ((messageTextView.text.characters.count + titleTextView.text.characters.count) > 121) {
            return false
        }
        return true
    }
    
    
/*
    Utility functions
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
    
    func clearTextAndImage() {
        self.titleTextView.text = ""
        self.messageTextView.text = ""
        self.imageView.image = UIImage(named: "CameraIcon")
    }
    
    
/*
    Camera functions
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
                self.imagePicker.sourceType = .Camera;
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
        
        imageView.image = image
        imageButton.imageView?.image = nil
        imageButton.titleLabel?.text = ""
        currentImage = image
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
/*
    CoreData functions
*/
    
    func saveCurrentBeat(uploaded: Bool) {
        // TODO: Should implement a type for the media ias parameter.
        
        // Initialize the Core Data model, this class encapsulates the notion of a .xcdatamodeld file
        // The name passed here should be the name of an .xcdatamodeld file//
        let model = CoreDataModel(name: ModelName, bundle: Bundle!)
        
        // Initialize a default stack
        let stack = CoreDataStack(model: model)
        
        _ = DataBeat(context: stack.mainQueueContext, title: currentBeat?.title, journeyId: userDefaults.stringForKey("activeJourneyId")!, message: currentBeat?.message, latitude: (currentBeat?.latitude)!, longitude: (currentBeat?.longitude)!, timestamp: (currentBeat?.timestamp)!, mediaType: "image", mediaData: currentBeat?.image, uploaded: uploaded)
        
        saveContext(stack.mainQueueContext) { (error: NSError?) in
            print(error)
            if error == nil {
                self.currentBeat = nil
            }
            // Do something if it goes wrong!
        }
    }

}

