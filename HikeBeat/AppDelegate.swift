//
//  AppDelegate.swift
//  HikeBeat
//
//  Created by Niklas Gundlev on 01/10/15.
//  Copyright © 2015 Niklas Gundlev. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var locManager: CLLocationManager = CLLocationManager()
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var reachability: Reachability!
    var currentlyShowingNotie = false
    var stack: CoreDataStack!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        self.startReachability()
        locManager.delegate = self;
        
        locManager.requestWhenInUseAuthorization()
        
        self.locManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locManager.distanceFilter = 1
        self.locManager.startUpdatingLocation()
        self.locManager.startUpdatingHeading()
        
        
        //        print("location manager started")
        //        print(locManager)
        
        if userDefaults.boolForKey("loggedIn") {
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewControllerWithIdentifier("TabBar")
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
        
        let model = CoreDataModel(name: ModelName, bundle: Bundle)
        let factory = CoreDataStackFactory(model: model)
        factory.createStackInBackground { (result: CoreDataStackResult) -> Void in
            switch result {
            case .Success(let s):
                print("Created stack! appDelegate")
                self.stack = s
            case .Failure(let err):
                print("Failed creating the stack! appDelegate")
                print(err)
            }
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        if reachability != nil {
            reachability.stopNotifier()
        }
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        self.startReachability()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func locationManagerShouldDisplayHeadingCalibration(manager: CLLocationManager) -> Bool {
        
        print("calibrating")
        return true
    }
    
    func synced() -> Bool? {
        if self.stack != nil {
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
        } else {
            return nil
        }
    }
    
    func startReachability() {
        
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            print("Unable to create Reachability")
            return
        }
        
        reachability.whenReachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            let sync = self.synced()
            if sync != nil {
                if !sync! {
                    if !self.currentlyShowingNotie {
                        self.currentlyShowingNotie = true
                        dispatch_async(dispatch_get_main_queue()) {
                            print("Reachable")
                            if let topController = UIApplication.sharedApplication().keyWindow?.rootViewController {
                                if #available(iOS 9.0, *) {
                                    let notie = Notie(view: topController.view, message: "Network connection! Would you like to start syncronizing now?", style: .Confirm)
                                    notie.leftButtonAction = {
                                        // Add your left button action here
                                        notie.dismiss()
                                        let progressNotie = Notie(view: topController.view, message: " ", style: .Progress)
                                        progressNotie.show()
                                        _ = Upload(notie: progressNotie, appDelegate: self)
                                    }
                                    notie.rightButtonAction = {
                                        // Add your right button action here
                                        notie.dismiss()
                                        self.currentlyShowingNotie = false
                                    }
                                    notie.show()
                                    notie.progressView.progress = 0
                                    
                                } else {
                                    // Fallback on earlier versions
                                }
                            }
                        }
                    }
                }
            }
            
                        
//                        if reachability.isReachableViaWiFi() {
//                            print("Reachable via WiFi")
//                            if let topController = UIApplication.sharedApplication().keyWindow?.rootViewController {
//                                    //topController = presentedViewController
//                                    if #available(iOS 9.0, *) {
//                                        print("gets here")
//                                        let notie = Notie(view: topController.view, message: "WiFi connection! Would you like to start syncronizing now?", style: .Confirm)
//                                        notie.leftButtonAction = {
//                                            // Add your left button action here
//                                            notie.dismiss()
//                                        }
//                                        
//                                        notie.rightButtonAction = {
//                                            // Add your right button action here
//                                            notie.dismiss()
//                                        }
//                                        
//                                        notie.show()
//                                    } else {
//                                        // Fallback on earlier versions
//                                    }
//                                //}
//                            }
//                        } else {
//                            print("Reachable via Cellular")
//                            if let topController = UIApplication.sharedApplication().keyWindow?.rootViewController {
//                                    //topController = presentedViewController
//                                    if #available(iOS 9.0, *) {
//                                        print("gets here")
//                                        let notie = Notie(view: topController.view, message: "Cullular connection! Would you like to start syncronizing now?", style: .Confirm)
//                                        notie.leftButtonAction = {
//                                            // Add your left button action here
//                                            notie.dismiss()
//                                        }
//                                        
//                                        notie.rightButtonAction = {
//                                            // Add your right button action here
//                                            notie.dismiss()
//                                        }
//                                        
//                                        notie.show()
//                                    } else {
//                                        // Fallback on earlier versions
//                                    }
//
//                            }
//                        }
                    
            
        }
        reachability.whenUnreachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            dispatch_async(dispatch_get_main_queue()) {
                print("Not reachable")
            }
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
/*
    Core Data Functions
*/
    
//    // MARK: - Core Data stack
//    
//    lazy var applicationDocumentsDirectory: NSURL = {
//        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.hikebeat.GetCoreData" in the application's documents Application Support directory.
//        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
//        return urls[urls.count-1]
//        }()
//    
//    lazy var managedObjectModel: NSManagedObjectModel = {
//        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
//        let modelURL = NSBundle.mainBundle().URLForResource("HikeBeatDataModel", withExtension: "momd")!
//        return NSManagedObjectModel(contentsOfURL: modelURL)!
//        }()
//    
//    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
//        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
//        // Create the coordinator and store
//        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
//        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
//        var failureReason = "There was an error creating or loading the application's saved data."
//        do {
//            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
//        } catch {
//            // Report any error we got.
//            var dict = [String: AnyObject]()
//            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
//            dict[NSLocalizedFailureReasonErrorKey] = failureReason
//            
//            dict[NSUnderlyingErrorKey] = error as NSError
//            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
//            // Replace this with code to handle the error appropriately.
//            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
//            abort()
//        }
//        
//        return coordinator
//        }()
//    
//    lazy var managedObjectContext: NSManagedObjectContext = {
//        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
//        let coordinator = self.persistentStoreCoordinator
//        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
//        managedObjectContext.persistentStoreCoordinator = coordinator
//        return managedObjectContext
//        }()
//    
//    // MARK: - Core Data Saving support
//    
//    func saveContext () {
//        if managedObjectContext.hasChanges {
//            do {
//                try managedObjectContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nserror = error as NSError
//                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
//                abort()
//            }
//        }
//    }
    
    
    
/*
    Utility functions
*/
    func getLocation() -> CLLocation? {
        
        var currentLocation: CLLocation?
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse){
            currentLocation = locManager.location
        }
        return currentLocation
    }


}

