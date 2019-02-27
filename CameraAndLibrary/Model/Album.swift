//
//  Album.swift
//  CameraAndLibrary
//
//  Created by can.khac.nguyen on 3/1/19.
//  Copyright © 2019 can.khac.nguyen. All rights reserved.
//

import Foundation
import Photos

class Album {
    let name: String
    let count: Int
    let collection: PHAssetCollection
    let latestImage: UIImage

    init(name: String, count: Int, collection: PHAssetCollection, latestImage: UIImage) {
        self.name = name
        self.count = count
        self.collection = collection
        self.latestImage = latestImage
    }
}
