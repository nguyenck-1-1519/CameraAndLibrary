//
//  ImageCollectionViewCell.swift
//  CameraAndLibrary
//
//  Created by can.khac.nguyen on 3/1/19.
//  Copyright © 2019 can.khac.nguyen. All rights reserved.
//

import UIKit
import Photos

class ImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var displayImageView: UIImageView!
    var assetsIdentifier: String?

    override func prepareForReuse() {
        super.prepareForReuse()
        displayImageView.image = nil
        assetsIdentifier = nil
    }
}
