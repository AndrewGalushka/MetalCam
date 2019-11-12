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
    
    var flag = false
    
    @IBAction func recordButtonTouchUpInsideActionHandler(_ button: UIButton) {
        
        if flag {
            button.setTitleColor(.blue, for: .normal)
            camera.finishRecording(completion: { url in
                
                PHPhotoLibrary.shared().performChanges({
                    PHAssetCreationRequest().addResource(with: .video, fileURL: url, options: nil)
                }) { (success, error) in
                    
                }
            })
        } else {
            camera.startRecording()
            button.setTitleColor(.red, for: .normal)
        }
        
        flag.toggle()
    }
}

