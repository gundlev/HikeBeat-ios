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
        let parameters = ["username": usernameTextField.text!, "password": passwordTextField.text!]

        /* Sending POST to API to check if the user exists. Will return a json with the user.*/
        Alamofire.request(.POST, "http://178.62.140.147/api/auth", parameters: parameters, headers: Headers).responseJSON { response in
            
//            print("\n\n")
//            print(data!.description)
//            print("\n\n")
//            print("\n\n")
            print(response)
            print(response.response?.statusCode)
            
//            print("\n\n")
//            print("\n\n")
//            print(request)
//            print("\n\n")
            
            if response.response?.statusCode == 200 {
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

                /* Stop wheel*/
                self.wheel.stopAnimating()
                
                /* Enter the app when logged in*/
                self.performSegueWithIdentifier("justLoggedIn", sender: self)
            } else if response.response?.statusCode == 401 {
                // User not authorized
                print("Not Auth!!")
                self.wheel.stopAnimating()
            } else if response.response?.statusCode == 400 {
                // Wrong username or password
                print("Wrong username or password")
                self.wheel.stopAnimating()
            }
            
            
        }
    }
    
    override func viewDidLoad() {
        wheel.hidesWhenStopped = true
        loginButton.layer.cornerRadius = 5;
        loginButton.layer.borderWidth = 1;
        loginButton.layer.borderColor = UIColor.whiteColor().CGColor
    }
}
