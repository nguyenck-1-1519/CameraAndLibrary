//
//  ImageCollectionViewCell.swift
//  CameraAndLibrary
//
//  Created by can.khac.nguyen on 3/1/19.
//  Copyright © 2019 can.khac.nguyen. All rights reserved.
//

import UIKit
import Photos

protocol ImageCellDelegate: class {
    func didFinishLoadThumb(image: UIImage?, indexPath: Int)
}

class ImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var displayImageView: UIImageView!
    weak var delegate: ImageCellDelegate?
    var indexPath: Int!

    func configCell(withAsset asset: PHAsset) {
        PhotoHelper.fetchImage(asset: asset,
                               contentMode: .aspectFit,
                               targetSize: CGSize(width: 90, height: 160),
                               deliveryMode: .fastFormat) { [weak self] img in
                                self?.displayImageView.image = img
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        displayImageView.image = nil
    }
}
