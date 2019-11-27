//
//  FaceRecognitionDecorator.swift
//  MetalCam
//
//  Created by Galushka on 21.11.2019.
//  Copyright © 2019 Galushka. All rights reserved.
//

import AVFoundation

class FaceRecognitionDecorator {
    private let faceRecognizer: VisionFaceRecognizer
    private let pixelBufferCopyPool = PixelBufferCopyPool()
    private var recognitionFrequency: RecognitionFrequency
    private var framesDropped: Int = 0
    
    init(faceRecognizer: VisionFaceRecognizer, recognitionFrequency: RecognitionFrequency = .everyFrame) {
        self.faceRecognizer = faceRecognizer
        self.recognitionFrequency = recognitionFrequency
    }
    
    func recognizeFace(pixelBuffer: CVPixelBuffer, orientation: CGImagePropertyOrientation) {
        guard canProcessNextFrame() else {
            return
        }
        
        faceRecognizer.recognizeFace(pixelBuffer: pixelBuffer, orientation: orientation)
    }
    
    private func canProcessNextFrame() -> Bool {
        switch recognitionFrequency {
        case .everyFrame:
            return true
        case .everyNFrame(let framesDropThreshold):
            
            if framesDropped % framesDropThreshold == 0 {
                framesDropped = 0
                return true
            } else {
                framesDropped += 1
                return false
            }
        }
    }
}

extension FaceRecognitionDecorator {
    enum RecognitionFrequency {
        case everyFrame
        case everyNFrame(Int)
    }
}
