//
//  SendChanges.swift
//  HikeBeat
//
//  Created by Niklas Gundlev on 18/12/15.
//  Copyright © 2015 Niklas Gundlev. All rights reserved.
//

import Foundation
import Alamofire
import UIKit

public func sendChanges(stack: CoreDataStack) {
    var changes = getChanges(stack)
    changes?.sortInPlace()
    if changes != nil {
        if changes?.count > 0 {
            for change in changes! {
                // Creating json changes object
                var jsonChanges = [String: AnyObject]()
                // Creating the array of changes even though there will only be one.
                var changesArray = [[String: AnyObject]]()
                // Printing the timeCommitted to see sequence
                print(change.timeCommitted)
                // Creating the change dictionary object
                var changeObject = [String : AnyObject]()
                // Setting property
                changeObject["property"] = change.property
                if change.stringValue == nil {
                    // The change is a bool value
                    changeObject["value"] = change.boolValue
                } else {
                    // The change is a stringvalue
                    changeObject["value"] = change.stringValue
                }
                // Adding change object to changes array
                changesArray.append(changeObject)
                // Adding changes array to json changes object
                jsonChanges["changes"] = changesArray
                
                // Sending the the change (printing now)
                print(jsonChanges.description)
            }
        } else {
            // There are no changes.
        }
    } else {
        // Fetch did not succeed.
    }
}

private func recursive(var arr: [Change]) {
    let change = arr.first
    
    // Creating json changes object
    var jsonChanges = [String: AnyObject]()
    // Creating the array of changes even though there will only be one.
    var changesArray = [[String: AnyObject]]()
    // Printing the timeCommitted to see sequence
    print(change!.timeCommitted)
    // Creating the change dictionary object
    var changeObject = [String : AnyObject]()
    // Setting property
    changeObject["property"] = change!.property
    if change!.stringValue == nil {
        // The change is a bool value
        changeObject["value"] = change!.boolValue
    } else {
        // The change is a stringvalue
        changeObject["value"] = change!.stringValue
    }
    // Adding change object to changes array
    changesArray.append(changeObject)
    // Adding changes array to json changes object
    jsonChanges["changes"] = changesArray
    
    // Sending the the change (printing now)
    print(jsonChanges.description)
    
    // Creating url
    let url = ""
    
    var notYet = true
    
    Alamofire.request(.PUT, url, parameters: jsonChanges, encoding: .JSON, headers: Headers).responseJSON { response in
        
        
        if response.response?.statusCode == 200 {
            print("It has been changes in the db")
            notYet = false
        } else {
            print("Something went wrong")
        }
    }
    while(notYet) {
        
    }
    
}

//func myThingy() -> Promise<AnyObject> {
//    return Promise{ fulfill, reject in
//        Alamofire.request(.GET, "http://httpbin.org/get", parameters: ["foo": "bar"]).response { (_, _, data, error) in
//            if error == nil {
//                fulfill(data)
//            } else {
//                reject(error)
//            }
//        }
//    }
//}


private func getChanges(stack: CoreDataStack) -> [Change]? {
    let changeEntity = entity(name: EntityType.Change, context: stack.mainContext)
    let fetchRequest = FetchRequest<Change>(entity: changeEntity)
    
    do {
        let result = try fetch(request: fetchRequest, inContext: stack.mainContext)
        return result
    } catch {
        print("The fetch failed")
        return nil
    }
}