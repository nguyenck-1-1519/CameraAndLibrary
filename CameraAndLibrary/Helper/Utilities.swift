//
//  Utilities.swift
//  CameraAndLibrary
//
//  Created by can.khac.nguyen on 3/4/19.
//  Copyright © 2019 can.khac.nguyen. All rights reserved.
//

import Foundation
import UIKit

class Utilities {

    func zoom(originalRect: CGRect, toPoint point: CGPoint, withScale scale: CGFloat, animated: Bool) {
        // new ContentSize
        var contentSize: CGSize = .zero
        contentSize.width = originalRect.size.width / scale
        contentSize.height = originalRect.size.height / scale

        // translate the zoom point to relative to the content rect
        
    }

}
