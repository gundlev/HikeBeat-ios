//
//  CreateUserVC.swift
//  HikeBeat
//
//  Created by Niklas Gundlev on 14/12/15.
//  Copyright © 2015 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class CreateUserVc: UIViewController {
    
/*
    Variables
*/
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    
/*
    IBOUtlets and IBActions
*/
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var repeatPassword: UITextField!
    
    @IBAction func createUser(sender: AnyObject) {
        if password.text == repeatPassword.text && email.text != "" && username.text != "" {
            
            let parameters = ["username": username.text!, "password": password.text!, "email": email.text!]
            
            Alamofire.request(.POST, IPAddress + "users", parameters: parameters, encoding: .JSON, headers: Headers).responseJSON { response in
                if response.response?.statusCode == 200 {
                    print("user has been created")
                    let user = JSON(response.result.value!)
                    
                    print("setting user")
                    self.userDefaults.setObject(user["username"].stringValue, forKey: "username")
                    
                    var optionsDictionary = [String:String]()
                    for (key, value) in user["options"].dictionaryValue {
                        optionsDictionary[key] = value.stringValue
                    }
                    
                    var journeyIdsArray = [String]()
                    for (value) in user["journeyIds"].arrayValue {
                        journeyIdsArray.append(value.stringValue)
                    }
                    
                    var followingArray = [String]()
                    for (value) in user["following"].arrayValue {
                        followingArray.append(value.stringValue)
                    }
                    
                    var deviceTokensArray = [String]()
                    for (value) in user["deviceTokens"].arrayValue {
                        deviceTokensArray.append(value.stringValue)
                    }
                    
                    var permittedPhoneNumbersArray = [String]()
                    for (value) in user["permittedPhoneNumbers"].arrayValue {
                        permittedPhoneNumbersArray.append(value.stringValue)
                    }
                    
                    self.userDefaults.setObject(optionsDictionary, forKey: "options")
                    self.userDefaults.setObject(journeyIdsArray, forKey: "journeyIds")
                    self.userDefaults.setObject(followingArray, forKey: "following")
                    self.userDefaults.setObject(deviceTokensArray, forKey: "deviceTokens")
                    self.userDefaults.setObject(user["_id"].stringValue, forKey: "_id")
                    self.userDefaults.setObject(user["username"].stringValue, forKey: "username")
                    self.userDefaults.setObject(user["email"].stringValue, forKey: "email")
                    self.userDefaults.setObject(user["activeJourneyId"].stringValue, forKey: "activeJourneyId")
                    self.userDefaults.setBool(true, forKey: "loggedIn")
                    self.userDefaults.setObject(permittedPhoneNumbersArray, forKey: "permittedPhoneNumbers")
                    
                    self.performSegueWithIdentifier("createdNewUser", sender: self)
                    
                } else if response.response?.statusCode == 400 {
                    // email or username has been uses
                    print("email or username has been uses")
                    print(response.response?.description)
                    
                }
            }
        } else {
            // The password an repeatPassword is not the same.
        }
    }
    
    override func viewDidLoad() {
        password.secureTextEntry = true
        repeatPassword.secureTextEntry = true
        
//        username.text = "gundlev"
//        email.text = "niklasgundlev@gmail.com"
//        password.text = "ABC123"
//        repeatPassword.text = "ABC123"
    }
    
    
}
