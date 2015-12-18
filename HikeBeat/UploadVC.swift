//
//  UploadVC.swift
//  HikeBeat
//
//  Created by Niklas Gundlev on 27/08/15.
//  Copyright © 2015 Niklas Gundlev. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
//import JSQCoreDataKit

class UploadVC: UIViewController {

    @IBOutlet weak var conLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var uploadButton: UIButton!
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var stack: CoreDataStack!
    var beats: [DataBeat]!
    
    @IBAction func logout(sender: AnyObject) {
        let success = syncWithAPI(stack)
        print("Success: ", success)
    }
    
    @IBOutlet weak var test: UIButton!
    @IBAction func performtest(sender: AnyObject) {
        let localBeats = getBeats()
        
        print("Now printing beats to be uplaoded:")
        for beat in localBeats! {
            print(beat.title)
            print(beat.mediaDataId)
            print(beat.mediaUploaded)
        }
    }
    
    @IBAction func uploadImages(sender: AnyObject) {
        
        self.beats = getBeats()
        
        for beat in beats {
            print(beat.title)
            print(beat.mediaUploaded)
            
            // Real solution
            
            /** Parameters to send to the API.*/
            let parameters = ["timeCapture": beat.timestamp, "journeyId": beat.journeyId, "data": beat.mediaData!]
            
            /** The URL for the post*/
            let url = IPAddress + "journeys/" + beat.journeyId + "/images"
            
            Alamofire.request(.POST, url, parameters: parameters, encoding: .JSON, headers: Headers).responseJSON { response in
                print(response)
                if response.response?.statusCode == 200 {
                    let json = JSON(response.result.value!)
                    print("Success for beat: ", beat.title)
                    beat.mediaDataId = json["_id"].stringValue
                    beat.mediaUploaded = true
                    saveContext(self.stack.mainContext)
                    self.progressView.progress = Float((100/self.beats.count)/100)
                }
            }
        }
            
            // Temporary solution
            
//            if Reachability.isConnectedToNetwork() {
//                // TODO: send via alamofire
//                let url = IPAddress + "journeys/" + beat.journeyId + "/messages"
//                print("url: ", url)
//                
//                // Parameters for the beat message
//                let parameters = ["headline": beat.title!, "text": beat.message!, "lat": beat.latitude, "lng": beat.longitude, "timeCapture": beat.timestamp, "journeyId": beat.journeyId]
//                
//                // Sending the beat message
//                Alamofire.request(.POST, url, parameters: parameters, encoding: .JSON, headers: Headers).responseJSON { response in
//                    print("The Response")
//                    print(response.response?.statusCode)
//                    
//                    // if response is 200 OK from server go on.
//                    if response.response?.statusCode == 200 {
//                        print("The text was send")
//                        
//                        // Save the messageId to the currentBeat
//                        let messageJson = JSON(response.result.value!)
//                        beat.messageId = messageJson["_id"].stringValue
//                        
//                        // If the is an image in the currentBeat, send the image.
//                        if beat.mediaData != nil {
//                            // Send Image
//                            /** Image Parameters including the image in base64 format. */
//                            let imageParams = ["timeCapture": beat.timestamp, "journeyId": beat.journeyId, "data": beat.mediaData!]
//                            
//                            /** The URL for the image*/
//                            let imageUrl = IPAddress + "journeys/" + beat.journeyId + "/images"
//                            
//                            // Sending the image.
//                            Alamofire.request(.POST, imageUrl, parameters: imageParams, encoding: .JSON, headers: Headers).responseJSON { imageResponse in
//                                // If everything is 200 OK from server save the imageId in currentBeat variable mediaDataId.
//                                if imageResponse.response?.statusCode == 200 {
//                                    let imageJson = JSON(imageResponse.result.value!)
//                                    print(imageResponse)
//                                    print("The image has been posted")
//                                    
//                                    // Set the imageId in currentBeat
//                                    print("messageId: ", imageJson["_id"].stringValue)
//                                    beat.mediaDataId = imageJson["_id"].stringValue
//                                    
//                                    // Set the uploaded variable to true as the image has been uplaoded.
//                                    beat.uploaded = true
//                                    saveContext(self.stack.mainContext)
//                                } else if imageResponse.response?.statusCode == 400 {
//                                    print("Error posting the image")
//                                }
//                            }
//                        } else {
//                            beat.uploaded = true
//                            saveContext(self.stack.mainContext)
//                        }
//                        saveContext(self.stack.mainContext)
//                    } else if response.response?.statusCode == 400 {
//                        // Error occured
//                        print("Error posting the message")
//                    }
//
//                    saveContext(self.stack.mainContext)
//                }
//            } else {
//                print("No network!")
//            }
            
            

        

        
        
//        let beats = self.getBeats()
//        
//        for beat in beats! {
//            if beat.uploaded == false {
//                print("Will now upload")
//                print(beat.title)
//                // TODO: Upload Image and set uploaded value to true.
//            } else {
//                print("Will not upload")
//                print(beat.title)
//            }
//        }
    }
    
    override func viewDidLoad() {
        //Something
        uploadButton.enabled = false
        let model = CoreDataModel(name: ModelName, bundle: Bundle)
        let factory = CoreDataStackFactory(model: model)
        factory.createStackInBackground { (result: CoreDataStackResult) -> Void in
            switch result {
            case .Success(let s):
                print("Created stack!")
                self.stack = s
                self.uploadButton.enabled = true
                
            case .Failure(let err):
                print("Failed creating the stack")
                print(err)
            }
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        if SimpleReachability.isConnectedToNetwork() {
            conLabel.text = "Connected To Network"
            uploadButton.enabled = true
        } else {
            conLabel.text = "No Connection"
            uploadButton.enabled = false
        }
    }
    
    
    // Need stackfactory implementation
    func getBeats() -> [DataBeat]? {
    

        let beatEntity = entity(name: EntityType.DataBeat, context: stack.mainContext)

        let fetchRequest = FetchRequest<DataBeat>(entity: beatEntity)
        fetchRequest.predicate = NSPredicate(format: "mediaUploaded == %@", false)
//        fetchRequest.predicate = NSPredicate(format: "mediaData != %@", "")
        
        do {
            let result = try fetch(request: fetchRequest, inContext: stack.mainContext)
            return result
        } catch {
            print("The fetch failed")
            return nil
        }
    }
}
