//
//  ImageData.swift
//  CameraAndLibrary
//
//  Created by can.khac.nguyen on 3/1/19.
//  Copyright © 2019 can.khac.nguyen. All rights reserved.
//

import UIKit
import Photos

struct ImageData {
    var previewImage: UIImage?
    var asset: PHAsset

    init(previewImage: UIImage?, asset: PHAsset) {
        self.previewImage = previewImage
        self.asset = asset
    }
}
