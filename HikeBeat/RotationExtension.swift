//
//  RotationExtension.swift
//  HikeBeat
//
//  Created by Niklas Gundlev on 10/03/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func correctlyOrientedImage() -> UIImage {
        if self.imageOrientation == UIImageOrientation.Up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.drawInRect(CGRectMake(0, 0, self.size.width, self.size.height))
        let normalizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return normalizedImage;
    }
}