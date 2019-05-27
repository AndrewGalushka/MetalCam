//
//  SharedDevice.swift
//  MetalCam
//
//  Created by Galushka on 5/27/19.
//  Copyright © 2019 Galushka. All rights reserved.
//

import MetalKit

class MetalSharedDevice {
    static let device: MTLDevice = MTLCreateSystemDefaultDevice()!
}
