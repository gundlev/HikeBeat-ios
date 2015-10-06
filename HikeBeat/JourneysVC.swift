//
//  JourneysVC.swift
//  HikeBeat
//
//  Created by Niklas Gundlev on 27/08/15.
//  Copyright © 2015 Niklas Gundlev. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import JSQCoreDataKit

class JourneysVC: UIViewController {

    @IBOutlet weak var conLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var uploadButton: UIButton!
    
    @IBAction func uploadImages(sender: AnyObject) {
        
        let beats = self.getBeats()
        
        for beat in beats! {
            if beat.uploaded == false {
                print("Will now upload")
                print(beat.title)
                // TODO: Upload Image and set uploaded value to true.
            } else {
                print("Will not upload")
                print(beat.title)
            }
        }
    }
    
    override func viewDidLoad() {
        //Something
    }
    
    override func viewWillAppear(animated: Bool) {
        if Reachability.isConnectedToNetwork() {
            conLabel.text = "Connected To Network"
            uploadButton.enabled = true
        } else {
            conLabel.text = "No Connection"
            uploadButton.enabled = false
        }
    }
    
    func getBeats() -> [DataBeat]? {
        
        let model = CoreDataModel(name: ModelName, bundle: Bundle!)

        // Initialize a default stack
        let stack = CoreDataStack(model: model)

        let beatEntity = entity(name: EntityType.DataBeat, context: stack.mainQueueContext)

        let fetchRequest = FetchRequest<DataBeat>(entity: beatEntity)
        do {
            let result = try fetch(request: fetchRequest, inContext: stack.mainQueueContext)

            print("Printing the fetched results")
            return result
        } catch {
            print("The fetch failed")
            return nil
        }
    }
}
