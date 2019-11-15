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
        previewView.mirroring = true
        return previewView
    }()
        
    private let videoWriter: VideoWritable = VideoWriter()
    private let fpsMeasurer = ManualFPSMeasurer()
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChangedHander(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
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
    
    func startRecording() {
        
        do {
            let url = FilePathGenerator.generatePath()
            try self.videoWriter.startRecording(url: url, frameDimensions: CGSize(width: 1280, height: 720))
        } catch let error {
            assert(false, error.localizedDescription)
        }
    }
    
    func finishRecording(completion: @escaping (Swift.Result<URL, Error>) -> Void) {
        self.videoWriter.finish(completion: completion)
    }
    
    @objc private func orientationDidChangedHander(_ notification: NSNotification) {
        switch UIDevice.current.orientation {
        case .unknown:
            return
        case .portrait:
            self.previewView.rotation = .rotate90Degrees
        case .portraitUpsideDown:
            self.previewView.rotation = .rotate270Degrees
        case .landscapeLeft:
            self.previewView.rotation = .rotate180Degrees
        case .landscapeRight:
            self.previewView.rotation = .rotate0Degrees
        case .faceUp:
            self.previewView.rotation = .rotate180Degrees
        case .faceDown:
            self.previewView.rotation = .rotate270Degrees
        @unknown default:
            return
        }
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    static var sigma = 0
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
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

        if videoWriter.isRecording {
            self.videoWriter.update(sampleBuffer: sampleBuffer)
        }
        
        self.previewView.pixelBuffer = imageBuffer
        CameraManager.sigma += 1
    }
}

extension CameraManager {
    fileprivate enum FilePathGenerator {
        static func generatePath() -> URL {
            let pathToTempDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
            return pathToTempDirectory.appendingPathComponent(UUID().uuidString, isDirectory: false).appendingPathExtension("mov")
        }
    }
}
 
