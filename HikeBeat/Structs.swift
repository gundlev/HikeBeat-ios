//
//  Structs.swift
//  HikeBeat
//
//  Created by Niklas Gundlev on 18/12/15.
//  Copyright © 2015 Niklas Gundlev. All rights reserved.
//

import Foundation

public struct MediaType {
    public static let image = "image"
    public static let video = "video"
    public static let audio = "audio"
    public static let none = "none"
}

public struct EntityType {
    public static let DataBeat = "DataBeat"
    public static let DataJourney = "DataJourney"
    public static let Change = "Change"
}

public struct ChangeAction {
    public static let update = "update"
    public static let delete = "delete"
}

public struct InstanceType {
    public static let journey = "journey"
    public static let beat = "beat"
    public static let user = "user"
}

public struct Property {
    public static let username = "username"
    public static let email = "email"
    public static let password = "password"
    public static let activeJourneyId = "activeJourneyId"
    public static let deviceToken = "deviceToken"
    public static let name = "options.name"
    public static let gender = "options.gender"
    public static let nationality = "options.nationality"
    public static let notifications = "options.notifications"
    public static let permittedPhoneNumbers = "options.permittedPhoneNumbers"
    public static let slug = "slug"
    public static let headline = "options.headline"
    public static let description = "options.description"
    public static let tags = "options.tags"
    public static let active = "options.active"
    public static let type = "options.type"
}

public struct UserProperty{
    public static let username = "username"
    public static let email = "email"
    public static let password = "password"
    public static let activeJourneyId = "activeJourneyId"
    public static let deviceToken = "deviceToken"
    public static let name = "options.name"
    public static let gender = "options.gender"
    public static let nationality = "options.nationality"
    public static let notifications = "options.notifications"
    public static let permittedPhoneNumbers = "options.permittedPhoneNumbers"
}

public struct JourneyProperty {
    public static let slug = "slug"
    public static let headline = "options.headline"
    public static let description = "options.description"
    public static let tags = "options.tags"
    public static let active = "options.active"
    public static let type = "options.type"
}
