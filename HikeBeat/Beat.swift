//
//  Beat.swift
//  HikeBeat
//
//  Created by Niklas Gundlev on 01/10/15.
//  Copyright © 2015 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit

class Beat: NSObject {
    
    var timestamp: String
    var latitude: String
    var longitude: String
    var journeyId: String
    var title: String?
    var message: String?
    var image: String?
    
    init(appDelegate: AppDelegate) {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        // Get current timestamp
        let currentDate = NSDate()
        let timeStamp = NSDateFormatter()
        timeStamp.dateFormat = "yyyyMMddHHmmss"
        let timeCapture = timeStamp.stringFromDate(currentDate)
        
        var longitude = ""
        var latitude = ""
        if let location = appDelegate.getLocation() {
            longitude = String(location.coordinate.longitude)
            latitude = String(location.coordinate.latitude)
        }
        
        self.timestamp = timeCapture
        self.latitude = latitude
        self.longitude = longitude
        self.journeyId = userDefaults.objectForKey("activeJourneyId") as! String
    }
    
    func createImageFromBase64() -> UIImage? {
        var image: UIImage? = nil
        if self.image != nil {
            if let data = NSData(base64EncodedString: self.image!, options: NSDataBase64DecodingOptions(rawValue: 0)) {
                if let img = UIImage(data: data) {
                    image = img
                }
            }
        }
        return image
    }
}
