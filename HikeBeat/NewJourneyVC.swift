//
//  NewJourneyVC.swift
//  HikeBeat
//
//  Created by Niklas Gundlev on 18/10/15.
//  Copyright © 2015 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class NewJourneyVC: UIViewController, UITextFieldDelegate {
    
    var stack: CoreDataStack!
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    
    @IBOutlet weak var slugInput: UITextField!
    @IBOutlet weak var headlineInput: UITextField!
    
    @IBAction func createJourney(sender: AnyObject) {
        
        if slugInput.text != "" && headlineInput.text != "" {
            let parameters: [String: AnyObject] = ["userId": (userDefaults.stringForKey("_id"))!, "slug": slugInput.text!, "options": ["headline": headlineInput.text!]]
            let url = IPAddress + "users/" + userDefaults.stringForKey("_id")! + "/journeys"
            
            Alamofire.request(.POST, url, parameters: parameters, headers: Headers).responseJSON { response in
                print(response.result.value)
                print(response.response?.statusCode)
                let json = JSON(response.result.value!)
                if response.response?.statusCode == 200 {
                    print("Journey Created!")
                    _ = DataJourney(context: self.stack.mainContext, slug: self.slugInput.text, userId: (self.userDefaults.stringForKey("_id"))!, journeyId: json["_id"].stringValue, headline: self.headlineInput.text, journeyDescription: nil, active: false, type: "straight")
                    saveContext(self.stack.mainContext)
                    self.performSegueWithIdentifier("toJourney", sender: self)
                }
            }
        } else {
            print("Fields has to be filled out!")
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    override func viewDidLoad() {
        self.navigationItem.title = "Create New Journey"
    }
}
