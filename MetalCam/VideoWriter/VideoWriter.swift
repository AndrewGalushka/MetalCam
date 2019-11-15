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
    private let pixelBufferCopier = PixelBufferCopyPool()
    
    private var state: State = .inactive {
        didSet {
            switch state {
            case .inactive: isRecording = false
            case .recording(_, _): isRecording = true
            }
        }
    }
    
    private(set) var isRecording: Bool = false
    
    func startRecording(url: URL, frameDimensions: CGSize) throws {
        self.processingQueue.async { [weak self] in
            do {
                guard let `self` = self else { return }
                assert(.inactive == self.state, "Unexpected state")
                
                let assetWriter = try AVAssetWriter(url: url, fileType: .mov)
                let assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: [AVVideoCodecKey: AVVideoCodecType.h264,
                                                                                              AVVideoWidthKey: frameDimensions.width,
                                                                                              AVVideoHeightKey: frameDimensions.height])
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
    
    func finish(completion: @escaping (Swift.Result<URL, Error>) -> Void) {
        self.processingQueue.async {  [weak self] in
            guard let `self` = self else { return }
            switch self.state {
            case .inactive:
                assert(false, "Unexpected state, should be .recording")
                return
            case .recording(let adapter, let assetWriter):
                
                if assetWriter.status == .failed {
                    if let error = assetWriter.error {
                        completion(.failure(error))
                        return
                    }
                    completion(.failure(NSError(domain: "video.writer.writing.error", code: 999, userInfo: nil)))
                    return
                }
                
                adapter.assetWriterInput.markAsFinished()
                assetWriter.finishWriting { [weak self] in
                    completion(.success(assetWriter.outputURL))
                }
                self.reset()
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
    
        if adapter.assetWriterInput.isReadyForMoreMediaData, let pixelBufferCopy = pixelBufferCopier.makeCopy(imageBuffer) {
            let isAppendingSuccess = adapter.append(pixelBufferCopy, withPresentationTime: presentationTime)
            
            if !isAppendingSuccess {
                print("\(#selector(AVAssetWriterInputPixelBufferAdaptor.append(_:withPresentationTime:))) is unsuccessful")
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

@propertyWrapper
class Atomic<Value> {
    private let queue = DispatchQueue(label: "com.vadimbulavin.atomic")
    private var value: Value

    init(wrappedValue: Value) {
        self.value = wrappedValue
    }
    
    var wrappedValue: Value {
        get {
            return queue.sync { value }
        }
        set {
            queue.sync { value = newValue }
        }
    }
    
    func mutate(_ mutation: (inout Value) -> Void) {
        queue.sync {
            mutation(&value)
        }
    }
    
    static func +=(lhs: Atomic<Value>, rhs: Value) -> Atomic<Value> {
        lhs.mutate {
            $0 = $0 + rhs
        }
    }
}
