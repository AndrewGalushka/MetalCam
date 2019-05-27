//
//  CameraManager.swift
//  MetalCam
//
//  Created by Galushka on 5/27/19.
//  Copyright © 2019 Galushka. All rights reserved.
//

import Foundation
import AVFoundation

class CameraManager: NSObject {
    private let camera: CameraType = Camera()
    
    func configure() {
        camera.configure()
    }
    
    func attach(to preview: AVCaptureVideoPreviewLayer) {
        camera.attach(to: preview)
    }
    
    func start() {
        camera.start()
    }
    
    func stop() {
        camera.stop()
    }
    
    func switchCamPosition() {
        camera.switchCamPosition()
    }
}
