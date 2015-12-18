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
    var stack: CoreDataStack!
    
    
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
        Alamofire.request(.POST, IPAddress + "auth", parameters: parameters, encoding: .JSON, headers: Headers).responseJSON { response in
            
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
                
                let options = user["options"].dictionaryValue
                
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
                self.userDefaults.setBool((options["notifications"]!.boolValue), forKey: "notifications")
                self.userDefaults.setObject((options["name"]!.stringValue), forKey: "name")
                self.userDefaults.setObject((options["gender"]!.stringValue), forKey: "gender")
                self.userDefaults.setObject((options["nationality"]!.stringValue), forKey: "nationality")

                /* Get all the journeys*/
                print("Getting the journeys")
                let urlJourney = IPAddress + "users/" + user["_id"].stringValue + "/journeys"
                print(urlJourney)
                Alamofire.request(.GET, urlJourney, encoding: .JSON, headers: Headers).responseJSON { response in
                    print(response.response?.statusCode)
                    //print(response)
                    if response.response?.statusCode == 200 {
                        if response.result.value != nil {
                            let json = JSON(response.result.value!)
                            print(json)
                            
                            for (_, journey) in json {
                                let headline = journey["options"]["headline"].stringValue
                                print(headline)
                                let active = user["activeJourneyId"].stringValue == journey["_id"].stringValue
                                
                                let dataJourney = DataJourney(context: self.stack.mainContext, slug: journey["slug"].stringValue, userId: user["_id"].stringValue, journeyId: journey["_id"].stringValue, headline: journey["options"]["headline"].stringValue, journeyDescription: journey["options"]["headline"].stringValue, active: active, type: journey["options"]["type"].stringValue)
                                saveContext(self.stack.mainContext)
                                
                                for (_, message) in journey["messages"]  {
                                    print("Slug: ", message["slug"].stringValue, " for journey: ", headline)
                                    //print(message)
                                    _ = DataBeat(context: self.stack.mainContext, title: message["headline"].stringValue, journeyId: journey["_id"].stringValue, message: message["text"].stringValue, latitude: message["lat"].stringValue, longitude: message["lng"].stringValue, timestamp: message["timeCapture"].stringValue, mediaType: MediaType.none, mediaData: "", mediaDataId: "", messageId: message["_id"].stringValue, mediaUploaded: true, messageUploaded: true, journey: dataJourney)
                                    saveContext(self.stack.mainContext)
                                    
                                }
                            }
                        }
                        
                    } else {
                        // something is wrong
                    }
                }
                
                
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
        
//        usernameTextField.text = "lindekaer"
//        passwordTextField.text = "gkBB1991"
        
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
    }
    
    func getBeats() -> [DataBeat]? {
        
        
        let beatEntity = entity(name: EntityType.DataBeat, context: stack.mainContext)
        
        let fetchRequest = FetchRequest<DataBeat>(entity: beatEntity)
        //fetchRequest.predicate = NSPredicate(format: "uploaded == %@", false)
        //        fetchRequest.predicate = NSPredicate(format: "mediaData != %@", "")
        
        do {
            let result = try fetch(request: fetchRequest, inContext: stack.mainContext)
            return result
        } catch {
            print("The fetch failed")
            return nil
        }
    }
}
