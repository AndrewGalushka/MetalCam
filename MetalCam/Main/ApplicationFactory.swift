//
//  ApplicationFactory.swift
//  MetalCam
//
//  Created by Galushka on 12.11.2019.
//  Copyright © 2019 Galushka. All rights reserved.
//

import Foundation

enum ApplicationFactory {
    static func makeDefaultRouter() -> ApplicationRoutable {
        return ApplicationRouter()
    }
}
