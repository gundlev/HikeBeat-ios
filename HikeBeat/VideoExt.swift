//
//  VideoExt.swift
//  VideoTestHB
//
//  Created by Niklas Gundlev on 16/01/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import Foundation
import AVFoundation
import MobileCoreServices
import Photos
import AVKit

extension SendBeatVC {
    
/*
    Requirements of ViewController to which this extension belong:
    
    IBActions:
        @IBAction func record(sender: AnyObject) {
        startRecordingVideo()
        }
        
        @IBAction func play(sender: AnyObject) {
        playVideo()
        }
*/
    
    func startRecordingVideo() {
        let optionsMenu = UIAlertController(title: "Choose resource for video", message: nil, preferredStyle: .ActionSheet)
        let cameraRoll = UIAlertAction(title: "Photo library", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Camera Roll")
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
                print("Button capture")
                
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .PhotoLibrary;
                self.imagePicker.mediaTypes = [kUTTypeMovie as String]
                self.imagePicker.allowsEditing = true
                self.imagePicker.videoMaximumDuration = 15
                
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }
        })
        let takePhoto = UIAlertAction(title: "Camera", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Take Photo")
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                
                print("captureVideoPressed and camera available.")
                
                let imagePicker = UIImagePickerController()
                
                imagePicker.delegate = self
                imagePicker.sourceType = .Camera;
                imagePicker.mediaTypes = [kUTTypeMovie as String]
                imagePicker.allowsEditing = false
                imagePicker.videoMaximumDuration = 15
                imagePicker.showsCameraControls = true
                imagePicker.videoQuality = UIImagePickerControllerQualityType.TypeHigh
                
                
                self.presentViewController(imagePicker, animated: true, completion: nil)
                
            }
                
            else {
                print("Camera not available.")
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
    
    func playVideo() {
        do {
            try playCurrentVideo()
        } catch AppError.InvalidResource(let name, let type) {
            debugPrint("Could not find resource \(name).\(type)")
        } catch {
            debugPrint("Generic error")
        }
    }
    
    func playVideoWithName(name: String) throws {
        let pathToFile = getPathToFileFromName(name)
        if pathToFile != nil {
            let player = AVPlayer(URL: pathToFile!)
            let playerController = AVPlayerViewController()
            playerController.player = player
            self.presentViewController(playerController, animated: true) {
                print("Playing video")
                player.play()
            }
        }

    }
    
    func getPathToFileFromName(name: String) -> NSURL? {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentDirectory = paths[0]
        let pathToFile = NSURL(fileURLWithPath: documentDirectory).URLByAppendingPathComponent(name)
        return pathToFile
    }
    
    private func playCurrentVideo() throws {
        let player = AVPlayer(URL: self.currentVideo!)
        let playerController = AVPlayerViewController()
        playerController.player = player
        self.presentViewController(playerController, animated: true) {
            print("Playing video")
            player.play()
        }
    }
    
    enum AppError : ErrorType {
        case InvalidResource(String, String)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let type = info[UIImagePickerControllerMediaType]
        print(type!.description)
        if type?.description! == "public.movie"{
            let videoURL = info[UIImagePickerControllerMediaURL] as! NSURL
            self.currentVideo = videoURL
            if picker.sourceType == .Camera {
                if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoURL.path!) {
                    UISaveVideoAtPathToSavedPhotosAlbum(videoURL.path!, self, nil, nil)
                }
            }
        } else {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            if picker.sourceType == .Camera {
                UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
            }
            self.mediaImageView.image = image
            currentImage = image
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveVideoToDocs(videoURL: NSURL, journeyId: String, timestamp: String) -> String? {
        let videoData = NSData(contentsOfURL: videoURL)
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentsDirectory: AnyObject = paths[0]
        let fileName = "hikebeat_"+journeyId+"_"+timestamp+".mp4"
        let dataPath = documentsDirectory.stringByAppendingPathComponent(fileName)
        let success = videoData!.writeToFile(dataPath, atomically: false)
        if success {
            return fileName
            print("Saved to Docs with name: ", fileName)
        } else {
            return nil
        }
    }
    
}
