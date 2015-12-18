//
//  Upload.swift
//  HikeBeat
//
//  Created by Niklas Gundlev on 16/12/15.
//  Copyright © 2015 Niklas Gundlev. All rights reserved.
//

import Foundation
import Alamofire
import UIKit

class Upload {
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var stack: CoreDataStack!
    var beats: [DataBeat]!
    
    @available(iOS 9.0, *)
    init(notie: Notie, appDelegate: AppDelegate) {
        let model = CoreDataModel(name: ModelName, bundle: Bundle)
        let factory = CoreDataStackFactory(model: model)
        factory.createStackInBackground { (result: CoreDataStackResult) -> Void in
            switch result {
            case .Success(let s):
                print("Created stack!")
                self.stack = s
                
                self.beats = self.getBeats()
                if self.beats?.count > 0 {
                    for beat in self.beats! {
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
                                print(1)
                                beat.mediaUploaded = true
                                print(2)
                                saveContext(self.stack.mainContext)
                                print(3)
                                print("progressView", notie.progressView)
                                //notie.progressView.progress = 0.5
                                print(4.5)
                                print("There are ", self.beats.count, " to be uploaded")
                                let increase = Float((100/Float(self.beats.count))/100)
                                print("Increasing progress by: ", increase)
                                print("Progress before: ", notie.progressView.progress)
                                notie.progressView.progress = notie.progressView.progress + increase
                                print("Progress after: ", notie.progressView.progress)
                                print(4)
                                if notie.progressView.progress == 1 {
                                    print(5)
                                    appDelegate.currentlyShowingNotie = false
                                    
                                    notie.dismiss()
                                }
                                print(5)
                            }
                        }
                    }
                } else {
                    notie.dismiss()
                }
                
            case .Failure(let err):
                print("Failed creating the stack")
                print(err)
            }
        }
    }
    
    func getBeats() -> [DataBeat]? {
        let beatEntity = entity(name: EntityType.DataBeat, context: stack.mainContext)
        let fetchRequest = FetchRequest<DataBeat>(entity: beatEntity)
        fetchRequest.predicate = NSPredicate(format: "mediaUploaded == %@", false)
        
        do {
            let result = try fetch(request: fetchRequest, inContext: stack.mainContext)
            return result
        } catch {
            print("The fetch failed")
            return nil
        }
    }
}
