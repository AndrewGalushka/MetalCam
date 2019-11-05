//
//  RecordingManagerType.swift
//  MetalCam
//
//  Created by Galushka on 6/3/19.
//  Copyright © 2019 Galushka. All rights reserved.
//

import AVFoundation

protocol RecordingManagerType {
    func startRecording(url: URL) throws
    func update(imageBuffer: CMSampleBuffer)
    func finish()
}

