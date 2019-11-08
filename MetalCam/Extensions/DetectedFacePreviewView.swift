//
//  DetectedFacesPreviewView.swift
//  MetalCam
//
//  Created by Galushka on 08.11.2019.
//  Copyright © 2019 Galushka. All rights reserved.
//

import UIKit

class DetectedFacePreviewView: UIView {
    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }
}

extension DetectedFacePreviewView: VisionFaceRecognizerDelegate {
    private var shapeLayer: CAShapeLayer! {
        return layer as? CAShapeLayer
    }
    
    func visionFaceRecognizer(_ visionFaceRecognizer: VisionFaceRecognizer, didFindRectangle normalizedRect: CGRect) {
        DispatchQueue.main.async {
            let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -self.frame.height)
            let translate = CGAffineTransform.identity.scaledBy(x: self.frame.width, y: self.frame.height)
            
            let faceRectangle = normalizedRect.applying(translate).applying(transform)
            self.shapeLayer.path = UIBezierPath(rect: faceRectangle).cgPath
            
            self.shapeLayer.lineWidth = 5.0
            self.shapeLayer.strokeColor = UIColor.red.cgColor
            self.shapeLayer.fillColor = UIColor.orange.withAlphaComponent(0.3).cgColor
        }
    }
}
