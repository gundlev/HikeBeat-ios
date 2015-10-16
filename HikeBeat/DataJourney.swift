//
//  DataJourney.swift
//  HikeBeat
//
//  Created by Niklas Gundlev on 12/10/15.
//  Copyright © 2015 Niklas Gundlev. All rights reserved.
//

import Foundation
import CoreData

public final class DataJourney: NSManagedObject {
    
    @NSManaged var slug: String?
    @NSManaged var userId: String
    @NSManaged var journeyId: String
    @NSManaged var headline: String?
    @NSManaged var journeyDescription: String?
    @NSManaged private var active: Bool
    @NSManaged var type: String
    @NSManaged var beats: Set<DataBeat>
    @NSManaged var activeString: String
    
    
    convenience init(
        context: NSManagedObjectContext,
        slug: String?,
        userId: String,
        journeyId: String,
        headline: String?,
        journeyDescription: String,
        active: Bool,
        type: String) {
            
        let entity = NSEntityDescription.entityForName(EntityType.DataJourney, inManagedObjectContext: context)
        self.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        self.slug = slug
        self.userId = userId
        self.journeyId = journeyId
        self.headline = headline
        self.journeyDescription = journeyDescription
        self.active = active
        self.type = type
            
        if active == true {
            self.activeString = "Active Journey"
        } else {
            self.activeString = "Finnished and Planned Journeys"
        }
    }
    
    func setActiveStatus(active: Bool) {
        switch active {
        case true:
            self.active = true
            self.activeString = "Active Journey"
        default:
            self.active = false
            self.activeString = "Finnished and Planned Journeys"
        }
    }
}