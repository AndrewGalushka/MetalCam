//
//  ViewController.swift
//  MetalCam
//
//  Created by Galushka on 5/24/19.
//  Copyright © 2019 Galushka. All rights reserved.
//

import UIKit
import Photos

class CameraViewController: UIViewController {

    // MARK: - Properties(Private)
    
    private let camera: CameraManager = CameraManager()
    @IBOutlet weak var videoCapturePreview: CaptureViewPreviewView!
    @IBOutlet weak var detectedFacePreview: DetectedFacePreviewView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        camera.configure()
        camera.setFaceRecognizerDelegate(detectedFacePreview)
        camera.attachOutput(to: videoCapturePreview)
        camera.start()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func switchCameraButtonTouchUpInsideActionHandler(_ sender: Any) {
        self.camera.switchCamPosition()
    }
    
    var isVideoRecording = false
    
    @IBAction func recordButtonTouchUpInsideActionHandler(_ button: UIButton) {
        
        if isVideoRecording {
            camera.finishRecording {
                switch $0 {
                case .success(let url):
                    self.saveVideoToLibrary(url: url)
                case .failure(let error):
                    print("recording is unsuccessful: \(error.localizedDescription)")
                }
            }
        } else {
            camera.startRecording()
        }
        
        button.setTitleColor(isVideoRecording ? .blue : .red, for: .normal)
        isVideoRecording.toggle()
    }
    
    private func saveVideoToLibrary(url: URL) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }) { (success, error) in
            
            if !success, let error = error {
                print("Creating video in Photos is unsuccessful: \(error.localizedDescription)")
            }
        }
    }
}

