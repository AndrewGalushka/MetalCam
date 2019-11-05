//
//  ManualFPSMeasurer.swift
//  PhoneBooth
//
//  Created by Galushka on 31.10.2019.
//  Copyright © 2019 User29. All rights reserved.
//

import Foundation

@objc class ManualFPSMeasurer: NSObject {
    private var subIntervalStartTime: CFAbsoluteTime = .zero
    
    @objc func measureSubInterval() {
     
        if self.subIntervalStartTime.isZero {
            self.subIntervalStartTime = CFAbsoluteTimeGetCurrent()
        }
        
        let fireTime = CFAbsoluteTimeGetCurrent()
        print("Time interval: --- \(fireTime - subIntervalStartTime)")
        self.subIntervalStartTime = fireTime
    }
    
    @objc func reset() {
        self.subIntervalStartTime = .zero
    }
}
