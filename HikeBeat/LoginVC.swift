//
//  LoginVC.swift
//  HikeBeat
//
//  Created by Niklas Gundlev on 29/09/15.
//  Copyright © 2015 Niklas Gundlev. All rights reserved.
//

import UIKit
import Alamofire

class LoginVC: UIViewController {
    
/*
    Variables
*/
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    
/*
    IBOutlets and IBActions
*/
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var wheel: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func loginTabbed(sender: AnyObject) {
        
        /* Starting the wheel*/
        wheel.startAnimating()
        
        /** Parameters to send to the API.*/
        let parameters = ["username": "Theodor", "password": "ABC123"]
        // usernameTextField.text!  passwordTextField.text!
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        /* Sending POST to API to check if the user exists. Will return a json with the user.*/
        Alamofire.request(.POST, "http://localhost/api/auth", parameters: parameters, headers: headers).authenticate(user: APIname, password: APIPass).response { request, response, data, error in
            
            print("\n\n")
            print(data!.description)
            print("\n\n")
            print("\n\n")
            print(response)
            print("\n\n")
            print("\n\n")
            print(request)
            print("\n\n")
            let user = getUserExample()
            
            // TODO: When you actually check for logion status see if you get an object back or a rejection be fore proceding.
            
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

            /* Stop wheel*/
            self.wheel.stopAnimating()
            
            /* Enter the app when logged in*/
            self.performSegueWithIdentifier("justLoggedIn", sender: self)
            
        }
    }
    
    override func viewDidLoad() {
        wheel.hidesWhenStopped = true
        loginButton.layer.cornerRadius = 5;
        loginButton.layer.borderWidth = 1;
        loginButton.layer.borderColor = UIColor.whiteColor().CGColor
    }
}
