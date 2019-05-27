//
//  CaptureViewPreviewView.swift
//  MetalCam
//
//  Created by Galushka on 5/24/19.
//  Copyright © 2019 Galushka. All rights reserved.
//

import UIKit
import AVFoundation

class CaptureViewPreviewView: UIView {
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return self.layer as! AVCaptureVideoPreviewLayer
    }
}
