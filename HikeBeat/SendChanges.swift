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


//TODO: Implement onError and completeWithFail


public func sendChanges(stack: CoreDataStack, progressView: UIProgressView, increase: Float) -> Future<Bool> {
    var changes = getChanges(stack)
    changes?.sortInPlace()
    let promise = Promise<Bool>()
//    if changes != nil {
//        if changes?.count > 0 {
            let future = asyncFunc(changes!, stack: stack, progressView: progressView, increase: increase)
            future.onSuccess(block: { (success) in
                if success {
                    promise.completeWithSuccess(success)
                } else {
                    promise.completeWithFail("One or more of the uploads failed.")
                }
            })
            return promise.future
//        } else {
//            // There are no changes.
//            return nil
//        }
//    } else {
//        // Fetch did not succeed.
//        return nil
//    }
}

private func asyncFunc(var arr: [Change], stack: CoreDataStack, progressView: UIProgressView, increase: Float) -> Future<Bool> {
    let change = arr.first
    
    // Creating json changes object
    var jsonChanges = [String: AnyObject]()
    
    if change?.changeAction != ChangeAction.delete {
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
    }

    
    // Creating url
    var url = ""
    switch change!.instanceType {
    case InstanceType.beat:
        url = IPAddress + "journeys/" + change!.instanceId! + "/messages/" + change!.timestamp!
    case InstanceType.journey:
        url = IPAddress + "users/" + userDefaults.stringForKey("_id")! + "/journeys/" + change!.instanceId!
    case InstanceType.user:
        url = IPAddress + "users/" + userDefaults.stringForKey("_id")!
    default: print("Creating the url failed.")
    }
    print("Now sending to url: ", url)
    
    // Creating the promise
    let p = Promise<Bool>()
    
    // Setting the HTTP method
    var method = Method.PUT
    switch change!.changeAction {
    case ChangeAction.delete:
        method = Method.DELETE
    case ChangeAction.update:
        method = Method.PUT
    default:
        method = Method.POST
    }
    
    // Sending change
    Alamofire.request(method, url, parameters: jsonChanges, encoding: .JSON, headers: Headers).responseJSON { response in
        if response.response?.statusCode == 200 {
            print(response.result.value)
            let removed = arr.removeFirst()
            deleteObjects([removed], inContext: stack.mainContext)
            saveContext(stack.mainContext)
            progressView.progress = progressView.progress + increase
            print("Uplaoded and removed change with value: ", removed.stringValue)
            if arr.isEmpty {
                p.completeWithSuccess(true)
            } else {
                let future = asyncFunc(arr,stack: stack, progressView: progressView, increase: increase)
                future.onSuccess(block: { success in
                    p.completeWithSuccess(success)
                })
            }
        } else {
            print("Something went wrong")
            p.completeWithSuccess(false)
        }
    }

    return p.future
}

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
