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
    
    // Devices
    private var frontDevice: AVCaptureDevice!
    private var backDevice: AVCaptureDevice!
    private var micDevice: AVCaptureDevice!
    
    // Current Camera Device
    private var currentCamDevice: AVCaptureDevice!
    private var position: CameraPosition = .back
    
    // Device Inputs
    private var deviceInput: AVCaptureDeviceInput!
    
    // CaptureSession
    private var captureSession: AVCaptureSession!
    
    // Outputs
    private var captureSessionOutput: AVCaptureVideoDataOutput!
        
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
    
        // Save internal state
        self.currentCamDevice = self.backDevice
        self.position = .back
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
    
    func switchCamPosition() {
        let device: AVCaptureDevice
        
        // Find current Device
        switch self.position {
        case .front:
            device = backDevice
        case .back:
            device = frontDevice
        }
        
        // Return if switching device is the same as current
        guard !device.isEqual(self.currentCamDevice) else {
            return
        }
        
        // Save switching to device
        self.currentCamDevice = device
        self.position.toggle()
        
        // Remove old device input from CamptureSesion
        self.captureSession.removeInput(self.deviceInput)
        
        // Create new device input with new device
        self.deviceInput = try! AVCaptureDeviceInput(device: self.currentCamDevice)
        
        // Add created device input to CaptureSession
        self.captureSession.addInput(self.deviceInput)
    }
    
    func setSampleBufferDelegate(_ sampleBufferDelegate: AVCaptureVideoDataOutputSampleBufferDelegate?, queue sampleBufferCallbackQueue: DispatchQueue?) {
        captureSessionOutput.setSampleBufferDelegate(sampleBufferDelegate, queue: sampleBufferCallbackQueue)
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

extension Camera {
    
    enum CameraPosition {
        case front
        case back
        
        mutating func toggle() {
            switch self {
            case .front:
                self = .back
            case .back:
                self = .front
            }
        }
    }
}
