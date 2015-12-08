//
//  DataBeat.swift
//  HikeBeat
//
//  Created by Niklas Gundlev on 05/10/15.
//  Copyright © 2015 Niklas Gundlev. All rights reserved.
//

import Foundation
import CoreData
import UIKit

public final class DataBeat: NSManagedObject, Comparable {
    
    @NSManaged var title: String?
    @NSManaged var journeyId: String
    @NSManaged var message: String?
    @NSManaged var latitude: String
    @NSManaged var longitude: String
    @NSManaged var timestamp: String
    @NSManaged var mediaType: String?
    @NSManaged var mediaData: String?
    @NSManaged var mediaDataId: String?
    @NSManaged var messageId: String?
    @NSManaged var uploaded: Bool
//    @NSManaged var hike: String
    @NSManaged var journey: DataJourney
    
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
        mediaDataId: String?,
        messageId: String?,
        uploaded: Bool,
//        hike: String,
        journey: DataJourney) {
            
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
        self.mediaDataId = mediaDataId
        self.messageId = messageId
        self.uploaded = uploaded
//        self.hike = hike
        self.journey = journey
            
    }
    
    func createImageFromBase64() -> UIImage? {
        var image: UIImage? = nil
        if self.mediaData != nil {
            if let data = NSData(base64EncodedString: self.mediaData!, options: NSDataBase64DecodingOptions(rawValue: 0)) {
                if let img = UIImage(data: data) {
                    image = img
                }
            }
        }
        return image
    }
}

public func <(lhs: DataBeat, rhs: DataBeat) -> Bool {
    return lhs.timestamp < rhs.timestamp
}

public func ==(lhs: DataBeat, rhs: DataBeat) -> Bool {
    return lhs.timestamp == rhs.timestamp
}
