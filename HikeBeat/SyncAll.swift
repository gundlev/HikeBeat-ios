//
//  SyncAll.swift
//  HikeBeat
//
//  Created by Niklas Gundlev on 21/12/15.
//  Copyright © 2015 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import CoreData
import BrightFutures

@available(iOS 9.0, *)
func syncAll(progressView: UIProgressView, stack: CoreDataStack) -> Future<Bool, NoError>? {
    // Performing fetch
    let tuble = getAll(stack)
    let promise = Promise<Bool, NoError>()
    
    // Check if fetch succeed.
    if tuble != nil {
        // get arrays from tuble
        let beats = tuble!.beats
        let changes = tuble!.changes
        
        // Figure increase to use for progressView
        let uploadsToDo = beats.count + changes.count
        let increase = Float((100/Float(uploadsToDo))/100)
        
        if beats.count > 0 {
            let beatFuture = sendBeats(beats, stack: stack, progressView: progressView, increase: increase)
            
            beatFuture.onSuccess{ (successBeats) in
                if changes.count > 0 {
                    let changeFuture = sendChanges(stack, progressView: progressView, increase: increase)
                    
                    changeFuture.onSuccess{ successChanges in
                        promise.success(successChanges && successBeats)
                    }
                } else {
                    promise.success(successBeats)
                }
            }
        } else if beats.count == 0 && changes.count > 0 {
            if changes.count > 0 {
                let changeFuture = sendChanges(stack, progressView: progressView, increase: increase)
                
                changeFuture.onSuccess{ success in
                    promise.success(success)
                }
            }
        } else {
            promise.success(true)
        }
        
        return promise.future
    } else {
        print("The fetch failed")
        return nil
    }
}

private func getAll(stack: CoreDataStack) -> (beats:[DataBeat], changes:[Change])? {
    let beatEntity = entity(name: EntityType.DataBeat, context: stack.mainContext)
    let fetchRequest = FetchRequest<DataBeat>(entity: beatEntity)
    let pred1 = NSPredicate(format: "mediaUploaded == %@", false)
    let pred2 = NSPredicate(format: "mediaData != %@", "")
    fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [pred1,pred2])
    
    let changeEntity = entity(name: EntityType.Change, context: stack.mainContext)
    let fetchReq = FetchRequest<Change>(entity: changeEntity)
    
    do {
        let beats = try fetch(request: fetchRequest, inContext: stack.mainContext)
        let changes = try fetch(request: fetchReq, inContext: stack.mainContext)
        return (beats, changes)
    } catch {
        print("The fetch failed")
        return nil
    }
}
