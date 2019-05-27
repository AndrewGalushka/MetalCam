//
//  UIViewController+Storyboard .swift
//  MetalCam
//
//  Created by Galushka on 5/24/19.
//  Copyright © 2019 Galushka. All rights reserved.
//

import UIKit

extension UIViewController {
    static func instantiateFromStoryboard() -> Self {
        let storyboard = UIStoryboard.init(name: "\(self)", bundle: Bundle(for: self))
        return instatiateViewController(self, from: storyboard)
    }
    
    static func instatiateViewController<T>(_ :T.Type, from storyboard: UIStoryboard) -> T {
        return storyboard.instantiateInitialViewController() as! T
    }
}


