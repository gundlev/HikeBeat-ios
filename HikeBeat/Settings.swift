//
//  Settings.swift
//  HikeBeat
//
//  Created by Niklas Gundlev on 21/09/15.
//  Copyright © 2015 Niklas Gundlev. All rights reserved.
//

import Foundation

let phoneNumber = "004530962591"

public let APIname = "bzb42utJUw1ZuWSJVmpLdwXMxScgwXOu4ZrAoL8spEJstyjuroTnnIts2m5Qgxo"
public let APIPass = "1dfpjdS6gmkDtdQQKbJVy4HezMK4mQYaIWgwyljbdYpMFJO3knQy012Lk2zBVS0"

public let IPAddress = "http://178.62.216.40/api/"

func getUserExample() -> JSON {
    
    let user: JSON = ["_id": "00000001","username": "nsg", "permittedPhoneNumbers": ["+4531585010", "+4528357657"], "email": "Niklas@gundlev.dk", "journeyIds": ["J1","J2","J4"], "options": ["name": "Niklas Stokkebro Gundlev", "gender": "Male", "nationality": "Denmark", "notifications": true], "following": ["U2","U3","U4"], "activeJourneyId": "J1", "deviceTokens": ["gfhkdsgafigudsbfudabslifbdksa", "fgdhsaægfildgbfldasbilfuda"]]

    return user
}
