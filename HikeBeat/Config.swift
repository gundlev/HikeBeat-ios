//
//  Settings.swift
//  HikeBeat
//
//  Created by Niklas Gundlev on 21/09/15.
//  Copyright © 2015 Niklas Gundlev. All rights reserved.
//

import Foundation
import CoreData
import UIKit

let phoneNumber = "004530962591"

public let APIname = "bzb42utJUw1ZuWSJVmpLdwXMxScgwXOu4ZrAoL8spEJstyjuroTnnIts2m5Qgxo"
public let APIPass = "1dfpjdS6gmkDtdQQKbJVy4HezMK4mQYaIWgwyljbdYpMFJO3knQy012Lk2zBVS0"
public let Headers = [
    "Content-Type": "application/x-www-form-urlencoded",
    "Authorization": "Basic YnpiNDJ1dEpVdzFadVdTSlZtcExkd1hNeFNjZ3dYT3U0WnJBb0w4c3BFSnN0eWp1cm9Ubm5JdHMybTVRZ3hvOjFkZnBqZFM2Z21rRHRkUVFLYkpWeTRIZXpNSzRtUVlhSVdnd3lsamJkWXBNRkpPM2tuUXkwMTJMazJ6QlZTMA=="
]

public let IPAddress = "https://hikebeat.rocks/api/"//"http://95.85.15.125:3000/api/"

func getUserExample() -> JSON {
    
    let user: JSON = ["_id": "00000001","username": "nsg", "permittedPhoneNumbers": ["+4531585010", "+4528357657"], "email": "Niklas@gundlev.dk", "journeyIds": ["J1","J2","J4"], "options": ["name": "Niklas Stokkebro Gundlev", "gender": "Male", "nationality": "Denmark", "notifications": true], "following": ["U2","U3","U4"], "activeJourneyId": "J1", "deviceTokens": ["gfhkdsgafigudsbfudabslifbdksa", "fgdhsaægfildgbfldasbilfuda"]]
    return user
}

func hex(number: Double) -> String {
    number
    let d = String(number)
    let e = d.rangeOfString(".")
    let s1 = d.substringToIndex((e?.startIndex)!)
    let s2 = d.substringFromIndex((e?.endIndex)!)
    let n1 = Int(s1)
    let n2 = Int(s2)
    if n2 == 0 {
        let st = String(n1!, radix: 36)
        return st
    }
    let st = String(n1!, radix: 36) + "." + String(n2!, radix: 36)
    return st
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

func alert(alertTitle: String, alertMessage: String, vc: UIViewController, actions:(title: String, style: UIAlertActionStyle, function: ()->())...) {
    let alertController = UIAlertController(title: alertTitle, message:
        alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
    
    for action in actions {
        alertController.addAction(UIAlertAction(title: action.title, style: action.style ,handler: {(alert: UIAlertAction!) in
            action.function()
        }))
    }
    vc.presentViewController(alertController, animated: true, completion: nil)
}

