//
//  ViewController+CollectionExt.swift
//  CameraAndLibrary
//
//  Created by can.khac.nguyen on 3/1/19.
//  Copyright © 2019 can.khac.nguyen. All rights reserved.
//

import Foundation
import UIKit

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listImage.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell",
                                 for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.indexPath = indexPath.row
        cell.delegate = self
        if listImage[indexPath.row].previewImage == nil {
            cell.configCell(withAsset: listImage[indexPath.row].asset)
        } else{
            cell.displayImageView.image = listImage[indexPath.row].previewImage
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "ImageDetailViewController") as? ImageDetailViewController else {
                return
        }
        viewController.asset = listImage[indexPath.row].asset
        present(viewController, animated: true, completion: nil)
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
}

extension ViewController: ImageCellDelegate {

    func didFinishLoadThumb(image: UIImage?, indexPath: Int) {
        listImage[indexPath].previewImage = image
    }

}
