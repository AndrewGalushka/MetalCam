//
//  CameraManager.swift
//  MetalCam
//
//  Created by Galushka on 5/27/19.
//  Copyright © 2019 Galushka. All rights reserved.
//

import Foundation
import AVFoundation
import CoreImage

class CameraManager: NSObject {
    private let camera: CameraType = Camera()
    private let processingQueue: DispatchQueue = DispatchQueue(label: "com.camera.manager.processing.queue")
    
    private var preview: CALayer?
    
    func configure() {
        camera.configure()
        camera.setSampleBufferDelegate(self, queue: processingQueue)
    }
    
    func attach(to preview: AVCaptureVideoPreviewLayer) {
        self.preview = preview
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

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let rotationTransform = CGAffineTransform.identity.rotated(by: CGFloat(-90 * Float.pi/180))
        let ciImage = CIImage(cvImageBuffer: imageBuffer).transformed(by: rotationTransform)
        
        let outputImage = CIFilter(name: "CICrystallize", parameters: ["inputImage": ciImage])?.outputImage
        
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(outputImage!, from: ciImage.extent)
        
        
        
        DispatchQueue.main.async {
            self.preview?.contents = cgImage
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
    }
}
