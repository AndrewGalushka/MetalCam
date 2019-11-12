//
//  ApplicationRouter.swift
//  MetalCam
//
//  Created by Galushka on 12.11.2019.
//  Copyright © 2019 Galushka. All rights reserved.
//

import UIKit

class ApplicationRouter: ApplicationRoutable {
    private var window: UIWindow = {
        let window = UIWindow(frame: UIScreen.main.bounds)
        return window
    }()
    
    func start() {
        window.rootViewController = CameraViewController.instantiateFromStoryboard()
        window.makeKeyAndVisible()
    }
}
