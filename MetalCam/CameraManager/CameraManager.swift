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
import CoreVideo

class CameraManager: NSObject {
    private let camera: CameraType = Camera()
    private lazy var visionFaceRecognizer: VisionFaceRecognizer = VisionFaceRecognizer()
    
    private let processingQueue: DispatchQueue = DispatchQueue(label: "com.camera.manager.processing.queue")
    private let faceProcessingQueue: DispatchQueue = DispatchQueue(label: "com.camera.manager.face.processing.queue")
    private let pixelBufferCopyPool = PixelBufferCopyPool()
    
    private var preview: AVCaptureVideoPreviewLayer?
    private var shapeLayer: CAShapeLayer?
    private let previewView: PreviewMetalView = {
        let previewView = PreviewMetalView()
        previewView.rotation = .rotate180Degrees
        previewView.mirroring = true
        return previewView
    }()
    
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
    
    func setFaceRecognizerDelegate(_ delegate: VisionFaceRecognizerDelegate?) {
        self.visionFaceRecognizer.delegate = delegate
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
    
    static var sigma = 0
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        fpsMeasurer.measureSubInterval()
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
    
        if CameraManager.sigma % 5 == 0 {
            
            if let pixelBufferCopy = self.pixelBufferCopyPool.makeCopy(imageBuffer){
                faceProcessingQueue.async {
                    self.visionFaceRecognizer.recognizeFace(pixelBuffer: pixelBufferCopy,
                                                            orientation: ExifOrientationConvertor.exifOrientationForCurrentDeviceOrientation())
                }
            }
        }

        
        self.previewView.pixelBuffer = imageBuffer
        CameraManager.sigma += 1
    }
}
