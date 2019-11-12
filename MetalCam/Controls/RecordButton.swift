//
//  RecordButton.swift
//  MetalCam
//
//  Created by Galushka on 12.11.2019.
//  Copyright © 2019 Galushka. All rights reserved.
//

import UIKit

class RecordButton: UIView {
    private lazy var underlyingButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = self.bounds
        return button
    }()
    
    private lazy var outerArcLayer: CALayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.borderWidth = 10
        shapeLayer.path = UIBezierPath(ovalIn: self.bounds).cgPath
        return CALayer()
    }()
    
    private lazy var innerCircleLayer: CALayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.red.cgColor
//        shapeLayer.path = UIBezierPath(
        return CALayer()
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func setupUI() {
        
    }
    
//    private func innerCirclePath =
}

private extension RecordButton {
    struct Configs {
        let outerArcThickness = 10
        let insetBetween = 2
    }
}
