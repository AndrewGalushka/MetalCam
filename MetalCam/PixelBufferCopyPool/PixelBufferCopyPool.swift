//
//  PixelBufferCopyPool.swift
//  MetalCam
//
//  Created by Galushka on 06.11.2019.
//  Copyright © 2019 Galushka. All rights reserved.
//

import CoreVideo

class PixelBufferCopyPool {
    
    private var pool: CVPixelBufferPool?
    
    func makeCopy(_ pixelBuffer: CVPixelBuffer) -> CVPixelBuffer? {
        let bufferDescription = PixelBufferDescription(pixelBuffer: pixelBuffer)
        
        if pool == nil {
            createPool(bufferDescription)
        }
        
        guard
            let pool = self.pool,
            let pixelBufferCopy = createPixelBuffer(using: pool, description: bufferDescription)
        else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        CVPixelBufferLockBaseAddress(pixelBufferCopy, .readOnly)
        
        self.copyBytes(from: pixelBuffer, to: pixelBufferCopy, bufferDescription: bufferDescription)
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        CVPixelBufferUnlockBaseAddress(pixelBufferCopy, .readOnly)
        
        return pixelBufferCopy
    }
    
    private func createPool(_ description: PixelBufferDescription) {
        let pixelBufferAttributes = [kCVPixelBufferIOSurfacePropertiesKey: [:],
                                     kCVPixelBufferWidthKey: description.width,
                                     kCVPixelBufferHeightKey: description.height,
                                     kCVPixelBufferPixelFormatTypeKey: description.pixelFormat] as [CFString : Any]
        let poolAttributes = [
            kCVPixelBufferPoolMinimumBufferCountKey: 30,
            kCVPixelBufferPoolMaximumBufferAgeKey: 3 // In seconds, 1 by default
        ]
        
        if kCVReturnSuccess != CVPixelBufferPoolCreate(kCFAllocatorDefault,
                                                       poolAttributes as CFDictionary,
                                                       pixelBufferAttributes as CFDictionary,
                                                       &self.pool) {
            assert(false, "Failed to create a pool")
            
            if self.pool != nil {
//                CVPixelBufferPoolFlush(pool, .excessBuffers)
                self.pool = nil
            }
        }
    }
    
    private func createPixelBuffer(using pool: CVPixelBufferPool, description: PixelBufferDescription) -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         description.width,
                                         description.height,
                                         description.pixelFormat,
                                         [kCVPixelBufferMetalCompatibilityKey: true] as CFDictionary,
                                         &pixelBuffer)
        
        assert(status == kCVReturnSuccess, "Failed to create pixel buffer from pool")
        
        return pixelBuffer
    }
    
    private func copyBytes(from pixelBuffer: CVPixelBuffer, to pixelBufferCopy: CVPixelBuffer, bufferDescription: PixelBufferDescription) {
        
        if bufferDescription.planes == 2 { // YUV
            let yDestPlane = CVPixelBufferGetBaseAddressOfPlane(pixelBufferCopy, 0)
            let yPlane = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0)
            memcpy(yDestPlane, yPlane, bufferDescription.width * bufferDescription.height)
            
            let uvDestPlane = CVPixelBufferGetBaseAddressOfPlane(pixelBufferCopy, 1)
            let uvPlane = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1)
            memcpy(uvDestPlane, uvPlane, bufferDescription.width * bufferDescription.height / 2)
        } else {
            let baseAddressCopy = CVPixelBufferGetBaseAddress(pixelBufferCopy)
            let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
            memcpy(baseAddressCopy, baseAddress, bufferDescription.height * bufferDescription.bytesPerRow)
        }
        
    }
}

extension PixelBufferCopyPool {
    private class PixelBufferDescription {
        let width: Int
        let height: Int
        let pixelFormat: OSType
        let bytesPerRow: Int
        let planes: Int
        
        
        init(pixelBuffer: CVPixelBuffer) {
            self.width = CVPixelBufferGetWidth(pixelBuffer)
            self.height = CVPixelBufferGetHeight(pixelBuffer)
            self.pixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer)
            self.bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
            self.planes = CVPixelBufferGetPlaneCount(pixelBuffer)
        }
    }
}
