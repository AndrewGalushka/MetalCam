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
    
    private let processingQueue = DispatchQueue(label: "videoWriter.appending.queue")
    
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
        self.processingQueue.async { [weak self] in
            do {
                guard let `self` = self else { return }
                assert(.inactive == self.state, "Unexpected state")
                
                let assetWriter = try AVAssetWriter(url: url, fileType: .mov)
                let assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: nil)
                assetWriterInput.expectsMediaDataInRealTime = true
                let assetWriterInputAdapter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: assetWriterInput, sourcePixelBufferAttributes: nil)
                
                self.assetWriter = assetWriter
                self.assetWriterInput = assetWriterInput
                self.assetWriterInputAdapter = assetWriterInputAdapter
                assetWriter.add(assetWriterInput)
                
                self.state = .recording(assetWriterInputAdapter, assetWriter)
            } catch {
                
            }
            
        }
        
    }
    
    func update(sampleBuffer: CMSampleBuffer) {
        self.processingQueue.async { [weak self] in
            guard let `self` = self else { return }
            switch self.state {
            case .inactive:
                assert(false, "Unexpected state, should be .recording")
                return
            case .recording(let pixelBufferAdapter, let assetWriter):
                self.appendSampleBuffer(sampleBuffer, adapter: pixelBufferAdapter, assetWriter: assetWriter)
            }
        }
    }
    
    func finish(completion: @escaping (URL) -> Void) {
        self.processingQueue.async {  [weak self] in
            guard let `self` = self else { return }
            switch self.state {
            case .inactive:
                assert(false, "Unexpected state, should be .recording")
                return
            case .recording(let adapter, let assetWriter):
                adapter.assetWriterInput.markAsFinished()
                assetWriter.finishWriting { [weak self] in
                    completion(assetWriter.outputURL)
                    self?.reset()
                }
            }
        }
    }
    
    private func appendSampleBuffer(_ sampleBuffer: CMSampleBuffer, adapter: AVAssetWriterInputPixelBufferAdaptor, assetWriter: AVAssetWriter) {
        let presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
   
        if assetWriter.status == .unknown {
            assetWriter.startWriting()
            assetWriter.startSession(atSourceTime: presentationTime)
        }
    
        if adapter.assetWriterInput.isReadyForMoreMediaData, let pool = adapter.pixelBufferPool {
            var pixelBufferCopy: CVPixelBuffer?
            CVPixelBufferPoolCreatePixelBuffer(nil, pool, &pixelBufferCopy)
            
            if let pixelBufferCopy = pixelBufferCopy {
                assert(adapter.append(pixelBufferCopy, withPresentationTime: presentationTime), "Something went wrong")
            }
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
