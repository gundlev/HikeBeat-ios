//
//  UtilityFunctions.swift
//  HikeBeat
//
//  Created by Niklas Gundlev on 17/12/15.
//  Copyright © 2015 Niklas Gundlev. All rights reserved.
//

import Foundation
import Alamofire

let userDefaults = NSUserDefaults.standardUserDefaults()


/*
    Sync with API to get changes made on the website.
*/


/**
    Creates a datastructure describing the current state of journeys and beats.

    - parameters:
        - CoreDataStack: stack

    - returns: [String: AnyObject]?
*/
private func createDataStructureForSync(stack: CoreDataStack) -> [String: AnyObject]? {
    let tuble = getAllLocalData(stack)
    
    
    if tuble != nil {
        let journeys = tuble!.journeys
        let beats = tuble!.beats
        
        var structure: [[String:AnyObject]] = [[String:AnyObject]]()
        for journey in journeys {
            var localObject = [String: AnyObject]()
            
            // Create beatId array
            var beatIds = [String]()
            for beat in beats {
                if beat.journeyId == journey.journeyId {
                    beatIds.append(beat.timestamp)
                }
            }
            
            localObject["journeyId"] = journey.journeyId
            localObject["messages"] = beatIds
            structure.append(localObject)
        }
        var endStructure = [String: AnyObject]()
        endStructure[userDefaults.stringForKey("_id")!] = structure
        
        return endStructure
    } else {
        return nil
    }
}

/**
    public function to sync with the API.
 
    - parameters:
        - CoreDataStack: stack
 
    - returns: Bool
 
*/
public func syncWithAPI(stack: CoreDataStack) -> Bool? {
    let data = createDataStructureForSync(stack)
    
    if data != nil {
        Alamofire.request(.POST, "http://httpbin.org/post", parameters: data, encoding: .JSON, headers: Headers).responseJSON { response in
            
            print("Response:")
            print(response)
        }
        return true
    } else {
        return nil
    }
}

/**
    Gets all local data from core data to be used for sync.
 
    - parameters:
        - CoreDataStack: Stack
 
    - returns: (journeys:[DataJourney], beats:[DataBeat])
*/
private func getAllLocalData(stack: CoreDataStack) -> (journeys:[DataJourney], beats:[DataBeat])? {
    let beatEntity = entity(name: EntityType.DataBeat, context: stack.mainContext)
    let bRequest = FetchRequest<DataBeat>(entity: beatEntity)
    let journeyEntity = entity(name: EntityType.DataJourney, context: stack.mainContext)
    let jRequest = FetchRequest<DataJourney>(entity: journeyEntity)
    
    do {
        let beats = try fetch(request: bRequest, inContext: stack.mainContext)
        let journeys = try fetch(request: jRequest, inContext: stack.mainContext)
        return (journeys, beats)
    } catch {
        print("The fetch failed")
        return nil
    }
}
