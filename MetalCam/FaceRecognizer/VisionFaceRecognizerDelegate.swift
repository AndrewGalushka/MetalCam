//
//  VisionFaceRecognizerDelegate.swift
//  MetalCam
//
//  Created by Galushka on 08.11.2019.
//  Copyright © 2019 Galushka. All rights reserved.
//

import Foundation
import CoreGraphics

protocol VisionFaceRecognizerDelegate {
    func visionFaceRecognizer(_ visionFaceRecognizer: VisionFaceRecognizer, didFindRectangle: CGRect)
}

extension VisionFaceRecognizerDelegate {
    func visionFaceRecognizer(_ visionFaceRecognizer: VisionFaceRecognizer, didFindRectangle: CGRect) {}
}
