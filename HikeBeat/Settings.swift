//
//  Settings.swift
//  HikeBeat
//
//  Created by Niklas Gundlev on 21/09/15.
//  Copyright © 2015 Niklas Gundlev. All rights reserved.
//

import Foundation
import CoreData

let phoneNumber = "004530962591"

public let APIname = "bzb42utJUw1ZuWSJVmpLdwXMxScgwXOu4ZrAoL8spEJstyjuroTnnIts2m5Qgxo"
public let APIPass = "1dfpjdS6gmkDtdQQKbJVy4HezMK4mQYaIWgwyljbdYpMFJO3knQy012Lk2zBVS0"
public let Headers = [
    "Content-Type": "application/x-www-form-urlencoded",
    "Authorization": "Basic YnpiNDJ1dEpVdzFadVdTSlZtcExkd1hNeFNjZ3dYT3U0WnJBb0w4c3BFSnN0eWp1cm9Ubm5JdHMybTVRZ3hvOjFkZnBqZFM2Z21rRHRkUVFLYkpWeTRIZXpNSzRtUVlhSVdnd3lsamJkWXBNRkpPM2tuUXkwMTJMazJ6QlZTMA=="
]

public let IPAddress = "http://178.62.140.147/api/"

func getUserExample() -> JSON {
    
    let user: JSON = ["_id": "00000001","username": "nsg", "permittedPhoneNumbers": ["+4531585010", "+4528357657"], "email": "Niklas@gundlev.dk", "journeyIds": ["J1","J2","J4"], "options": ["name": "Niklas Stokkebro Gundlev", "gender": "Male", "nationality": "Denmark", "notifications": true], "following": ["U2","U3","U4"], "activeJourneyId": "J1", "deviceTokens": ["gfhkdsgafigudsbfudabslifbdksa", "fgdhsaægfildgbfldasbilfuda"]]

    return user
}

func getNewJourney(context: NSManagedObjectContext, active: Bool) -> DataJourney {
    
    let rand = randomStringWithLength(5)
    
    let journey = DataJourney(context: context, slug: "Journey-" + (rand as String), userId: NSUUID().UUIDString, journeyId: "56253f2b30f2c21d7905cdac", headline: "My awesome trip " + (rand as String), journeyDescription: "I am going to travel around the great coutry of " + (rand as String), active: active, type: "straight")
    
    return journey
}

func randomStringWithLength (len : Int) -> NSString {
    
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    
    let randomString : NSMutableString = NSMutableString(capacity: len)
    
    for (var i=0; i < len; i++){
        let length = UInt32 (letters.length)
        let rand = arc4random_uniform(length)
        randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
    }
    
    return randomString
}