//
//  Change.swift
//  HikeBeat
//
//  Created by Niklas Gundlev on 18/12/15.
//  Copyright © 2015 Niklas Gundlev. All rights reserved.
//

import Foundation
import CoreData
import UIKit

public final class Change: NSManagedObject, Comparable {
    
    @NSManaged var instanceType: String
    @NSManaged var timeCommitted: String
    @NSManaged var stringValue: String?
    @NSManaged var boolValue: Bool
    @NSManaged var property: String?
    @NSManaged var instanceId: String?
    @NSManaged var changeAction: String
    @NSManaged var timestamp: String?
    
    convenience init(
        context: NSManagedObjectContext,
        instanceType: String,
        timeCommitted: String,
        stringValue: String?,
        boolValue: Bool,
        property: String?,
        instanceId: String?,
        changeAction: String,
        timestamp: String?) {
            
        let entity = NSEntityDescription.entityForName(EntityType.Change, inManagedObjectContext: context)
        self.init(entity: entity!, insertIntoManagedObjectContext: context)
            
        self.instanceType = instanceType
        self.timeCommitted = timeCommitted
        self.stringValue = stringValue
        self.boolValue = boolValue
        self.property = property
        self.instanceId = instanceId
        self.changeAction = changeAction
        self.timestamp = timestamp
    }
    
}

public func <(lhs: Change, rhs: Change) -> Bool {
    return lhs.timeCommitted < rhs.timeCommitted
}

public func ==(lhs: Change, rhs: Change) -> Bool {
    return lhs.timeCommitted == rhs.timeCommitted
}
