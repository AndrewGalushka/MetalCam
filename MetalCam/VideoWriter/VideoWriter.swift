//
//  RecordingManager.swift
//  MetalCam
//
//  Created by Galushka on 6/3/19.
//  Copyright © 2019 Galushka. All rights reserved.
//

import AVFoundation

class VideoWriter: VideoWritable {
    private var assetWriter: AVAssetWriter?
    private var assetWriterInput: AVAssetWriterInput?
    private var assetWriterInputAdapter: AVAssetWriterInputPixelBufferAdaptor?
    
    private var state: State = .inactive {
        didSet {
            switch state {
            case .inactive: isRecording = false
            case .recording(_, _): isRecording = true
            }
        }
    }
    
    private(set) var isRecording: Bool = false
    
    func startRecording(url: URL) throws {
        
        assert(.inactive == self.state, "Unexpected state")
        
        let assetWriter = try AVAssetWriter(url: url, fileType: .mov)
        let assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: nil)
        assetWriterInput.expectsMediaDataInRealTime = true
        let assetWriterInputAdapter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: assetWriterInput, sourcePixelBufferAttributes: nil)
        self.assetWriter = assetWriter
        self.assetWriterInput = assetWriterInput
        self.assetWriterInputAdapter = assetWriterInputAdapter
        
        self.state = .recording(assetWriterInputAdapter, assetWriter)
        
        assetWriter.startWriting()
    }
    
    func update(sampleBuffer: CMSampleBuffer) {
        switch state {
        case .inactive:
            assert(false, "Unexpected state, should be .recording")
            return
        case .recording(let pixelBufferAdapter, _):
            self.appendSampleBuffer(sampleBuffer, adapter: pixelBufferAdapter)
        }
    }
    
    func finish(completion: @escaping (URL) -> Void) {
        switch state {
        case .inactive:
            assert(false, "Unexpected state, should be .recording")
            return
        case .recording(_, let assetWriter):
            assetWriter.finishWriting { [weak self] in
                completion(assetWriter.outputURL)
                self?.reset()
            }
        }
    }
    
    private func appendSampleBuffer(_ sampleBuffer: CMSampleBuffer, adapter: AVAssetWriterInputPixelBufferAdaptor) {
        let presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        if adapter.assetWriterInput.isReadyForMoreMediaData {
            adapter.append(imageBuffer, withPresentationTime: presentationTime)
        }
    }
    
    private func reset() {
        self.assetWriterInputAdapter = nil
        self.assetWriterInput = nil
        self.assetWriter = nil
        self.state = .inactive
    }
}

private extension VideoWriter {
    enum State: Equatable {
        case inactive
        case recording(AVAssetWriterInputPixelBufferAdaptor, AVAssetWriter)
    }
}

private extension VideoWriter {
    
}
