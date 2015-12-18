//
//  ProfileVC.swift
//  HikeBeat
//
//  Created by Niklas Gundlev on 27/08/15.
//  Copyright © 2015 Niklas Gundlev. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
//import JSQCoreDataKit

class ProfileVC: UIViewController {
    
    var stack: CoreDataStack!
    var count = 0

    @IBAction func createChange(sender: AnyObject) {
        let CurrentTime = CACurrentMediaTime()
        let change = Change(context: stack.mainContext, instanceType: InstanceType.journey, timeCommitted: String(CurrentTime), stringValue: String(self.count++), boolValue: false, property: JourneyProperty.headline, instanceId: "hd74qhody80iho3q298bf9oh", changeAction: ChangeAction.update)
        saveContext(stack.mainContext)
    }
    
    @IBAction func printChanges(sender: AnyObject) {
        sendChanges(self.stack)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let model = CoreDataModel(name: ModelName, bundle: Bundle)
        let factory = CoreDataStackFactory(model: model)
        factory.createStackInBackground { (result: CoreDataStackResult) -> Void in
            switch result {
            case .Success(let s):
                print("Created stack!")
                self.stack = s
            case .Failure(let err):
                print("Failed creating the stack")
                print(err)
            }
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

