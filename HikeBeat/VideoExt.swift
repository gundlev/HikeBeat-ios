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
                self.imagePicker.videoQuality = UIImagePickerControllerQualityType.TypeHigh
                
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
                imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureMode.Video
                imagePicker.allowsEditing = true
                imagePicker.videoMaximumDuration = 15
                imagePicker.showsCameraControls = true
                imagePicker.videoQuality = UIImagePickerControllerQualityType.TypeMedium
                //self.imagePicker
                
                
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
            
            // user chose video
            let currentVideoURL = info[UIImagePickerControllerMediaURL] as! NSURL
            self.currentMediaURL = currentVideoURL
            if picker.sourceType == .Camera {
                if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(currentVideoURL.path!) {
                    UISaveVideoAtPathToSavedPhotosAlbum(currentVideoURL.path!, self, nil, nil)
                }
            }
        } else {
            
            // User chose image
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            if picker.sourceType == .Camera {
                UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
            }
            self.mediaImageView.image = image
            currentImage = image
            print(1)
//            let currentImageURL = info[UIImagePickerControllerMediaURL] as! NSURL
//            self.currentMediaURL = currentImageURL
            print(2)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveMediaToDocs(mediaData: NSData, journeyId: String, timestamp: String) -> String? {
        print(1.1)
//        let videoData = NSData(contentsOfURL: mediaURL)
        print(1.2)
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        print(1.3)
        let documentsDirectory: AnyObject = paths[0]
        print(1.4)
        let fileName = "hikebeat_"+journeyId+"_"+timestamp+".mp4"
        let dataPath = documentsDirectory.stringByAppendingPathComponent(fileName)
        let success = mediaData.writeToFile(dataPath, atomically: false)
        print(1.5)
        if success {
            print("Saved to Docs with name: ", fileName)
            return fileName
        } else {
            return nil
        }
    }
    
    func removeMediaWithURL(mediaURL: NSURL) {
        let fm = NSFileManager()
        do {
            try fm.removeItemAtURL(mediaURL)
        } catch {
            print("problem removing media ")
        }
    }
}
