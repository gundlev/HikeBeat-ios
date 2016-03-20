//
//  utils.swift
//  HikeBeat
//
//  Created by Niklas Gundlev on 31/01/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

public func getPathToFileFromName(name: String) -> NSURL? {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    let documentDirectory = paths[0]
    let pathToFile = NSURL(fileURLWithPath: documentDirectory).URLByAppendingPathComponent(name)
    return pathToFile
}

public func covertToMedia(pathToInputFile : NSURL, pathToOuputFile: NSURL, fileType: String) -> Bool {
    
    let asset = AVAsset(URL: pathToInputFile)
    
    let session = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough)
    
    print(AVAssetExportSession.exportPresetsCompatibleWithAsset(asset))
    
    session?.outputURL = pathToOuputFile
    session?.outputFileType = fileType
    
    session?.exportAsynchronouslyWithCompletionHandler({ () -> Void in
        print("The session is done exporting")
    })
    
    let assetOut = AVAsset(URL: pathToOuputFile)
    
    print(assetOut.description)
    
    return true
}
