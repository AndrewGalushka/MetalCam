//
//  VideoWritable.swift
//  MetalCam
//
//  Created by Galushka on 6/3/19.
//  Copyright © 2019 Galushka. All rights reserved.
//

import AVFoundation

protocol VideoWritable {
    var isRecording: Bool { get }
    func startRecording(url: URL, frameDimensions: CGSize) throws
    func update(sampleBuffer: CMSampleBuffer)
    func finish(completion: @escaping (Swift.Result<URL, Error>) -> Void)
}

