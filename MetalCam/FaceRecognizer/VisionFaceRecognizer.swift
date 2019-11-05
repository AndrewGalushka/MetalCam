//
//  VisionFaceRecognizer.swift
//  PhoneBooth
//
//  Created by Galushka on 31.10.2019.
//  Copyright © 2019 User29. All rights reserved.
//

import Vision
import CoreMedia

@objc class VisionFaceRecognizer: NSObject {
    
    private var objectDetectionRequests: [VNDetectFaceRectanglesRequest]?
    private var trackingRequests: [VNTrackObjectRequest]?
    private var sequenceRequestHandler: VNSequenceRequestHandler?
    private let fpsMeasurer = ManualFPSMeasurer()
    
    @objc func prepare() {
        let faceDetectionRequest = VNDetectFaceRectanglesRequest(completionHandler: self.faceRectanglesDetectionCompletionHandler)
        self.objectDetectionRequests = [faceDetectionRequest]
        self.sequenceRequestHandler = VNSequenceRequestHandler()
    }
    
    fileprivate func faceRectanglesDetectionCompletionHandler(_ request: VNRequest, _ error: Error?) {
        if error != nil {
            print("FaceDetection error: \(String(describing: error)).")
        }
        
        guard
            let faceDetectionRequest = request as? VNDetectFaceRectanglesRequest,
            let results = faceDetectionRequest.results as? [VNFaceObservation]
        else {
            return
        }
        
        var requests = [VNTrackObjectRequest]()
        // Add the observations to the tracking list
        for observation in results {
            let faceTrackingRequest = VNTrackObjectRequest(detectedObjectObservation: observation)
            requests.append(faceTrackingRequest)
        }
        
        self.trackingRequests = requests
    }
    
    @objc func recognizeFace(pixelBuffer: CVPixelBuffer, orientation: CGImagePropertyOrientation) {
        
        var requestHandlerOptions: [VNImageOption: AnyObject] = [:]
        
        if let cameraIntrinsicData = CMGetAttachment(pixelBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
            requestHandlerOptions[VNImageOption.cameraIntrinsics] = cameraIntrinsicData
        }
        
        guard
            let trackingRequests = self.trackingRequests,
            !trackingRequests.isEmpty
        else {
            self.detectObjectsToTrack(pixelBuffer: pixelBuffer, orientation: orientation, options: requestHandlerOptions)
            return
        }
        
        guard let sequenceRequestHandler = self.sequenceRequestHandler else {
            return
        }
        
        do {
            try sequenceRequestHandler.perform(trackingRequests,
                                               on: pixelBuffer,
                                               orientation: orientation)
        } catch let error {
            print(error)
        }
        
        var newTrackingRequests = [VNTrackObjectRequest]()
        for trackingRequest in trackingRequests {
            
            guard let results = trackingRequest.results else {
                return
            }
            
            guard let observation = results[0] as? VNDetectedObjectObservation else {
                return
            }
            
            if !trackingRequest.isLastFrame {
                if observation.confidence > 0.3 {
                    trackingRequest.inputObservation = observation
                } else {
                    trackingRequest.isLastFrame = true
                }
                newTrackingRequests.append(trackingRequest)
            }
        }
        self.trackingRequests = newTrackingRequests
        
        if newTrackingRequests.isEmpty {
            // Nothing to track, so abort.
            return
        }
    }
        
    private func detectObjectsToTrack(pixelBuffer: CVPixelBuffer, orientation: CGImagePropertyOrientation, options:  [VNImageOption : Any]) {
        guard let objectDetectionRequests = self.objectDetectionRequests else {
            return
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                                        orientation: orientation,
                                                        options: options)
        
        do {
            try imageRequestHandler.perform(objectDetectionRequests)
        } catch let error {
            print(error)
        }
    }
}
