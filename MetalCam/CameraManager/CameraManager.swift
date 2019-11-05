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
import UIKit

class CameraManager: NSObject {
    private let camera: CameraType = Camera()
    private let visionFaceRecognizer = VisionFaceRecognizer()
    private let processingQueue: DispatchQueue = DispatchQueue(label: "com.camera.manager.processing.queue")
    
    private var preview: AVCaptureVideoPreviewLayer?
    private let previewView: PreviewMetalView = PreviewMetalView()
    private let fpsMeasurer = ManualFPSMeasurer()
    
    func configure() {
        self.visionFaceRecognizer.prepare()
        camera.configure()
        camera.setSampleBufferDelegate(self, queue: processingQueue)
    }
    
    func attachOutput(to view: UIView) {
        previewView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(previewView)
        
        previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        previewView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        previewView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
//    func attach(to preview: AVCaptureVideoPreviewLayer) {
//        self.preview = preview
//        self.camera.attach(to: preview)
//    }
    
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
        fpsMeasurer.measureSubInterval()
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        previewView.pixelBuffer = imageBuffer
        
        DispatchQueue.global().async {
            self.visionFaceRecognizer.recognizeFace(pixelBuffer: imageBuffer, orientation: self.exifOrientationForCurrentDeviceOrientation())
        }
        
//        let rotationTransform = CGAffineTransform.identity.rotated(by: CGFloat(-90 * Float.pi/180))
//        let ciImage = CIImage(cvImageBuffer: imageBuffer) //.transformed(by: rotationTransform)
//
//        let context = CIContext(options: nil)
//        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    }
    
    private func handleOutputImageBuffer(_ imageBuffer: CVImageBuffer) {
        
    }
    
    private func record() {
        let path = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("recoreded_video")
        
        let assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: nil)
        let assetWriterInputAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: assetWriterInput, sourcePixelBufferAttributes: nil)
        let assetWriter = try! AVAssetWriter(outputURL: path, fileType: .mov)
        assetWriter.add(assetWriterInput)
    }
    
    func exifOrientationForDeviceOrientation(_ deviceOrientation: UIDeviceOrientation) -> CGImagePropertyOrientation {
        
        switch deviceOrientation {
        case .portraitUpsideDown:
            return .rightMirrored
            
        case .landscapeLeft:
            return .downMirrored
            
        case .landscapeRight:
            return .upMirrored
            
        default:
            return .leftMirrored
        }
    }
    
    func exifOrientationForCurrentDeviceOrientation() -> CGImagePropertyOrientation {
        return exifOrientationForDeviceOrientation(UIDevice.current.orientation)
    }
}
