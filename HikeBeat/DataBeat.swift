//
//  DataBeat.swift
//  HikeBeat
//
//  Created by Niklas Gundlev on 05/10/15.
//  Copyright © 2015 Niklas Gundlev. All rights reserved.
//

import Foundation
import CoreData

public final class DataBeat: NSManagedObject {
    
    @NSManaged var title: String?
    @NSManaged var journeyId: String
    @NSManaged var message: String?
    @NSManaged var latitude: String
    @NSManaged var longitude: String
    @NSManaged var timestamp: String
    @NSManaged var mediaType: String?
    @NSManaged var mediaData: String?
    @NSManaged var uploaded: Bool
    
    convenience init(
        context: NSManagedObjectContext,
        title: String?,
        journeyId: String,
        message: String?,
        latitude: String,
        longitude: String,
        timestamp: String,
        mediaType: String?,
        mediaData: String?,
        uploaded: Bool) {
            
        let entity = NSEntityDescription.entityForName(EntityType.DataBeat, inManagedObjectContext: context)
        self.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        self.title = title
        self.journeyId = journeyId
        self.message = message
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
        self.mediaType = mediaType
        self.mediaData = mediaData
        self.uploaded = uploaded
            
    }
}
