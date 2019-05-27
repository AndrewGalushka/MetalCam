//
//  CameraType.swift
//  MetalCam
//
//  Created by Galushka on 5/27/19.
//  Copyright © 2019 Galushka. All rights reserved.
//

import Foundation
import AVFoundation

protocol CameraType {
    func configure()
    func attach(to preview: AVCaptureVideoPreviewLayer)
    func start()
    func stop()
    func switchCamPosition()
}
