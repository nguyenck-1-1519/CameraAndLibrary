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
        return fetchResult?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell",
                                 for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        guard let asset = fetchResult?.object(at: indexPath.item) else { return UICollectionViewCell() }
        cell.assetsIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: thumbnailSize,
                                  contentMode: .aspectFill, options: nil) { (image, _) in
                                    if cell.assetsIdentifier == asset.localIdentifier {
                                        cell.displayImageView.image = image
                                    }
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "ImageDetailViewController") as? ImageDetailViewController else {
                return
        }
        viewController.asset = fetchResult?.object(at: indexPath.item)
        present(viewController, animated: true, completion: nil)
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return thumbnailSize
    }
}
