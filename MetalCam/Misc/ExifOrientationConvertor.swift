//
//  ExifOrientationConvertor.swift
//  MetalCam
//
//  Created by Galushka on 06.11.2019.
//  Copyright © 2019 Galushka. All rights reserved.
//

import UIKit
import CoreGraphics

class ExifOrientationConvertor {
    static func exifOrientationForDeviceOrientation(_ deviceOrientation: UIDeviceOrientation) -> CGImagePropertyOrientation {
        
        switch deviceOrientation {
        case .portraitUpsideDown:
            return .rightMirrored
            
        case .landscapeLeft:
            return .downMirrored
            
        case .landscapeRight:
            return .upMirrored
            
        default:
            return .leftMirrored
        }
    }
    
    static func exifOrientationForCurrentDeviceOrientation() -> CGImagePropertyOrientation {
        return exifOrientationForDeviceOrientation(UIDevice.current.orientation)
    }
}
