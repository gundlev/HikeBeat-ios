//
//  UploadBeats.swift
//  HikeBeat
//
//  Created by Niklas Gundlev on 21/12/15.
//  Copyright © 2015 Niklas Gundlev. All rights reserved.
//

import Foundation
import CoreData
import Alamofire
import BrightFutures
import UIKit

func sendBeats(beats: [DataBeat], stack: CoreDataStack, progressView: UIProgressView, increase: Float) -> Future<Bool, NoError> {
    
    let promise = Promise<Bool, NoError>()
    var count = 0
    for beat in beats {
        print(beat.title)
        print(beat.mediaUploaded)
        
        // Real solution
        
        /** Parameters to send to the API.*/
       // let parameters: [String: AnyObject] = ["timeCapture": beat.timestamp, "journeyId": beat.journeyId, "data": beat.mediaData!]
        
        var customHeader = Headers
        customHeader["x-hikebeat-timecapture"] = beat.timestamp
        customHeader["x-hikebeat-type"] = beat.mediaType!
        
        let filePath = getPathToFileFromName(beat.mediaData!)
        
        /** The URL for the post*/
        let url = IPAddress + "journeys/" + beat.journeyId + "/media"
        
        Alamofire.upload(.POST, url, headers: customHeader, file: filePath!).progress { bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in
            //print(totalBytesWritten)
            
            // This closure is NOT called on the main queue for performance
            // reasons. To update your ui, dispatch to the main queue.
            dispatch_async(dispatch_get_main_queue()) {
                print("Total bytes written on main queue: \(totalBytesWritten)")
                print("Bytes writtn now: \(totalBytesWritten)")
                let byteIncreasePercentage = Float(bytesWritten) / Float(totalBytesExpectedToWrite)
                let localIncrease = increase * byteIncreasePercentage
                progressView.progress = progressView.progress + localIncrease
            }
        }.responseJSON { response in
            print("This is the media response: ", response)
            if response.response?.statusCode == 200 {
                let json = JSON(response.result.value!)
                print("Success for beat: ", beat.title)
                beat.mediaDataId = json["_id"].stringValue
                print(1)
                beat.mediaUploaded = true
                print(2)
                saveContext(stack.mainContext)
                print(3)
                print("progressView: ", progressView)
                //progressView.progress = 0.5
                print(4.5)
                print("There are ", beats.count, " to be uploaded")
                //let increase = Float((100/Float(beats.count))/100)
//                print("Increasing progress by: ", increase)
//                print("Progress before: ", progressView.progress)
//                progressView.progress = progressView.progress + increase
//                print("Progress after: ", progressView.progress)
                print(4)
                count++
                if count == beats.count {
                    print(5)
                    promise.success(true)
                    //                    appDelegate.currentlyShowingNotie = false
                }
                //print(5)
            } else {
                promise.success(false)
            }
            
        }
        
//        Alamofire.request(.POST, url, parameters: parameters, encoding: .JSON, headers: Headers).responseJSON { response in
//            print(response)
//            if response.response?.statusCode == 200 {
//                let json = JSON(response.result.value!)
//                print("Success for beat: ", beat.title)
//                beat.mediaDataId = json["_id"].stringValue
//                print(1)
//                beat.mediaUploaded = true
//                print(2)
//                saveContext(stack.mainContext)
//                print(3)
//                print("progressView: ", progressView)
//                //progressView.progress = 0.5
//                print(4.5)
//                print("There are ", beats.count, " to be uploaded")
////                let increase = Float((100/Float(beats.count))/100)
//                print("Increasing progress by: ", increase)
//                print("Progress before: ", progressView.progress)
//                progressView.progress = progressView.progress + increase
//                print("Progress after: ", progressView.progress)
//                print(4)
//                count++
//                if count == beats.count {
//                    print(5)
//                    promise.success(true)
////                    appDelegate.currentlyShowingNotie = false
//                }
//                //print(5)
//            } else {
//                promise.success(false)
//            }
//        }
    }
    return promise.future
}
