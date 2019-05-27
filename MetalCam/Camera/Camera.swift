//
//  Camera.swift
//  MetalCam
//
//  Created by Galushka on 5/24/19.
//  Copyright © 2019 Galushka. All rights reserved.
//

import Foundation
import AVFoundation

class Camera: CameraType {
    private var frontDevice: AVCaptureDevice!
    private var backDevice: AVCaptureDevice!
    private var micDevice: AVCaptureDevice!
    
    private var deviceInput: AVCaptureDeviceInput!
    
    private var captureSession: AVCaptureSession!
    
    private var captureSessionOutput: AVCaptureOutput!
    
    func configure() {
        
        // Discover for devices and initialize properties
        self.frontDevice = self.discoverFrontDevice()
        self.backDevice = self.discoverBackDevice()
        self.micDevice = self.discoverMicDevice()
        
        // Add Input to Discovered device (back camera)
        self.deviceInput = try! AVCaptureDeviceInput(device: backDevice)
        
        // Initialize AVCaptureSession
        self.captureSession = AVCaptureSession()
        
        // Add Input to CaptureSession
        captureSession.addInput(self.deviceInput)
        
        // Initialize CaptureOutput
        self.captureSessionOutput = AVCaptureVideoDataOutput()
        
        // Add output to CaptureSession
        captureSession.addOutput(captureSessionOutput)
    }
    
    func attach(to preview: AVCaptureVideoPreviewLayer) {
        preview.session = self.captureSession
    }
    
    func start() {
        captureSession.startRunning()
    }
    
    func stop() {
        captureSession.stopRunning()
    }
    
    private func discoverBackDevice() -> AVCaptureDevice {
        let backDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera, .builtInDualCamera, .builtInWideAngleCamera],
                                                                          mediaType: .video,
                                                                          position: AVCaptureDevice.Position.back)
        
        return backDeviceDiscoverySession.devices.first!
    }
    
    private func discoverFrontDevice() -> AVCaptureDevice {
        let backDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera, .builtInDualCamera, .builtInWideAngleCamera],
                                                                          mediaType: .video,
                                                                          position: AVCaptureDevice.Position.front)
        
        return backDeviceDiscoverySession.devices.first!
    }
    
    private func discoverMicDevice() -> AVCaptureDevice {
        let micDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInMicrophone],
                                                                         mediaType: AVMediaType.audio,
                                                                         position: .unspecified)

        return micDeviceDiscoverySession.devices.first!
    }
}

