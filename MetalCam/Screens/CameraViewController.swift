//
//  ViewController.swift
//  MetalCam
//
//  Created by Galushka on 5/24/19.
//  Copyright © 2019 Galushka. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {

    // MARK: - Properties(Private)
    
    private let camera: CameraManager = CameraManager()
    @IBOutlet weak var videoCapturePreview: CaptureViewPreviewView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        camera.configure()
        camera.attachOutput(to: videoCapturePreview)
        camera.start()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func switchCameraButtonTouchUpInsideActionHandler(_ sender: Any) {
        self.camera.switchCamPosition()
    }
}

