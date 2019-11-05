//
//  RecordingManager.swift
//  MetalCam
//
//  Created by Galushka on 6/3/19.
//  Copyright © 2019 Galushka. All rights reserved.
//

import AVFoundation

class RecordingManager: RecordingManagerType {
    
    private var assetWriter: AVAssetWriter?
    private var assetWriterInput: AVAssetWriterInput?
    private var assetWriterInputAdapter: AVAssetWriterInputPixelBufferAdaptor?
    
    func startRecording(url: URL) throws {
        let assetWriter = try AVAssetWriter(url: url, fileType: .mov)
        let assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: nil)
        assetWriterInput.expectsMediaDataInRealTime = true
        let assetWriterInputAdapter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: assetWriterInput, sourcePixelBufferAttributes: nil)
        
        self.assetWriter = assetWriter
        self.assetWriterInput = assetWriterInput
        self.assetWriterInputAdapter = assetWriterInputAdapter
        
        assetWriter.startWriting()
    }
    
    func update(imageBuffer: CMSampleBuffer) {
        let presentationTime = CMSampleBufferGetPresentationTimeStamp(imageBuffer)
    }
    
    func finish() {
        
    }
}
