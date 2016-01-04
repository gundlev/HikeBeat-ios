//
//  SettingsVC.swift
//  HikeBeat
//
//  Created by Niklas Gundlev on 12/12/15.
//  Copyright © 2015 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class SettingsVC: FormViewController {
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var stack: CoreDataStack!
    
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
        
        navigationAccessoryView.hidden = true
        
//        let stuff = ["one", "two", "three"]
        
        form +++= Section(header: "Settings", footer: " ")
            
            <<< SwitchRow() {
                    $0.title = "Notifications"
                    $0.value = userDefaults.boolForKey("notifications")
                }.onChange({ (SwitchRow) -> () in
                    print("Value changed to: ", SwitchRow.value)
                    self.notificationChange(SwitchRow.value!)
                })
            
            <<< SwitchRow() {
                $0.title = "GPS Check"
                $0.value = userDefaults.boolForKey("GPS-check")
                }.onChange({ (SwitchRow) -> () in
                    print("Value changed to: ", SwitchRow.value)
                    self.userDefaults.setObject(SwitchRow.value, forKey: "GPS-check")
                })
            
            <<< ButtonRow("Sync now") { row in
                    row.title = row.tag
                    row.onCellSelection({ (cell, row) -> () in
                        if SimpleReachability.isConnectedToNetwork() {
                            print("Have network")
                            let synced = self.appDelegate.synced()
                            if synced != nil {
                                print("synced is not nil")
                                print("synced value: ", synced)
                                if !synced! {
                                    print("There are things to sync")
                                    self.sync()
                                }
                            }
                        }
                    })
                }
    
            <<< ButtonRow("Logout") { row in
                    row.title = row.tag
                    row.onCellSelection({ (cell, row) -> () in
                        self.logout()
                    })
                }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func notificationChange(value: Bool) {
        
        userDefaults.setBool(value, forKey: "notifications")
        
        if SimpleReachability.isConnectedToNetwork() {
            let parameters:[String: AnyObject] = ["changes": [[
                                                        "property"  :   "options.notifications",
                                                        "value"     :   value
                                                ]]]
            let url = IPAddress + "users/" + userDefaults.stringForKey("_id")!
            print(url)
            Alamofire.request(.PUT, url, parameters: parameters, encoding: .JSON, headers: Headers).responseJSON { response in
                
                if response.response?.statusCode == 200 {
                    print("It has been changes in the db")
                    ChangeAction.update
                } else {
                    print("No connection or fail, saving change")
                    _ = Change(context: self.stack.mainContext, instanceType: InstanceType.user, timeCommitted: String(CACurrentMediaTime()), stringValue: nil, boolValue: value, property: UserProperty.notifications, instanceId: nil, changeAction: ChangeAction.update, timestamp: nil)
                    saveContext(self.stack.mainContext)
                }
            }
        } else {
            // Save to changes data structure when created.
            _ = Change(context: self.stack.mainContext, instanceType: InstanceType.user, timeCommitted: String(CACurrentMediaTime()), stringValue: nil, boolValue: value, property: UserProperty.notifications, instanceId: nil, changeAction: ChangeAction.update, timestamp: nil)
            saveContext(self.stack.mainContext)
        }
    }
    
    func sync() {
        if #available(iOS 9.0, *) {
            let progressNotie = Notie(view: self.view, message: " ", style: .Progress)
            progressNotie.show()
            self.appDelegate.currentlyShowingNotie = true
            let future = syncAll(progressNotie.progressView, stack: self.stack)
            
            if future != nil {
                future!.onSuccess{ success in
                    progressNotie.dismiss()
                    self.appDelegate.currentlyShowingNotie = false
                    if success {
                        print("All is syncronized!")
                    } else {
                        print("Not everything was syncronized!")
                    }
                }
            } else {
                print("Failed to fetch")
                progressNotie.dismiss()
            }
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    func logout() {
        
        let isSynced = self.synced()
        
        if (isSynced != nil) {
            if isSynced! {
                // All is synced!
                alert(
                    "Are you sure",
                    alertMessage: "Logging back in requires network connection",
                    vc: self,
                    actions:
                        (title: "Logout", style: UIAlertActionStyle.Default, function: {
                            print("Logging out")
                            self.performSegueWithIdentifier("logout", sender: self)
                        }),
                    
                        (title: "Cancel", style: UIAlertActionStyle.Cancel, function: {
                        })
                    )
                
            } else {
                // There are unsyced data
                alert(
                    "Unsyncronized data!",
                    alertMessage: "There are unsyncronized data in this device. If you logout, this data will be lost",
                    vc: self,
                    actions:
                        (title: "Logout", style: UIAlertActionStyle.Default, function: {
                            print("Logging out")
                            self.performSegueWithIdentifier("logout", sender: self)
                        }),
                    
                        (title: "Cancel", style: UIAlertActionStyle.Cancel, function: {
                        })
                )
            }
            
        } else {
            // somethign went wrong with the fecthing
            alert(
                "Are you sure",
                alertMessage: "ogging back in requires network connection",
                vc: self,
                actions:
                    (title: "Logout", style: UIAlertActionStyle.Default, function: {
                        print("Logging out")
                        self.performSegueWithIdentifier("logout", sender: self)
                    }),
                
                    (title: "Cancel", style: UIAlertActionStyle.Cancel, function: {
                    })
            )
        }
    }
    
    
    // Need stackfactory implementation
    func synced() -> Bool? {
        let beatEntity = entity(name: EntityType.DataBeat, context: stack.mainContext)
        
        let fetchRequest = FetchRequest<DataBeat>(entity: beatEntity)
        fetchRequest.predicate = NSPredicate(format: "mediaUploaded == %@", false)
        //        fetchRequest.predicate = NSPredicate(format: "mediaData != %@", "")
        
        do {
            let result = try fetch(request: fetchRequest, inContext: stack.mainContext)
            if result.count == 0 {
                return true
            } else {
                return false
            }
        } catch {
            print("The fetch failed")
            return nil
        }
    }
    
    func deleteAllData() {
        let beatEntity = entity(name: EntityType.DataBeat, context: stack.mainContext)
        let journeyEntity = entity(name: EntityType.DataJourney, context: stack.mainContext)
        
        let reqBeat = FetchRequest<DataBeat>(entity: beatEntity)
        let reqJourney = FetchRequest<DataJourney>(entity: journeyEntity)
        
        do {
            let beats = try fetch(request: reqBeat, inContext: stack.mainContext)
            let journeys = try fetch(request: reqJourney, inContext: stack.mainContext)
            print("Journeys fetched",journeys)
            deleteObjects(beats, inContext: stack.mainContext)
            deleteObjects(journeys, inContext: stack.mainContext)
            saveContext(stack.mainContext)
        } catch {
            print("The fetch of all objects failed")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "logout":
            print("Logout segue")
            
            // Removing the user information.
            let appDomain = NSBundle.mainBundle().bundleIdentifier!
            NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain)
            
            // Removing the Core Data
            deleteAllData()
            
        default: print("Unknown Segue")
        }
    }
}