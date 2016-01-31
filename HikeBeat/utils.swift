//
//  utils.swift
//  HikeBeat
//
//  Created by Niklas Gundlev on 31/01/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit

public func getPathToFileFromName(name: String) -> NSURL? {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    let documentDirectory = paths[0]
    let pathToFile = NSURL(fileURLWithPath: documentDirectory).URLByAppendingPathComponent(name)
    return pathToFile
}
