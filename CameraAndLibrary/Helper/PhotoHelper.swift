//
//  PhotoHelper.swift
//  CameraAndLibrary
//
//  Created by can.khac.nguyen on 2/28/19.
//  Copyright © 2019 can.khac.nguyen. All rights reserved.
//

import Photos
import UIKit

public class PhotoHelper {

    class func trySaveimage(_ image: UIImage, inAlbumNamed name: String) {
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            if let album = album(named: name) {
                saveImage(image, toAlbum: album)
            } else {
                createAlbum(withName: name) {
                    if let album = album(named: name) {
                        saveImage(image, toAlbum: album)
                    }
                }
            }
        }
    }

//    class func getAllAssets() -> [ImageData] {
//        let fetchOptions = PHFetchOptions()
//        let sortOrder = [NSSortDescriptor(key: "creationDate", ascending: false)]
//        fetchOptions.sortDescriptors = sortOrder
//        let allAssets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
//        var imagesData = [ImageData]()
//        for index in 0..<allAssets.count {
//            let imageData = ImageData(previewImage: nil, asset: allAssets[index])
//            imagesData.append(imageData)
//        }
//        return imagesData
//    }

//    class func getAllPhotos() -> [ImageData?] {
//        let fetchOptions = PHFetchOptions()
//        let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
//        var imagesData = [ImageData?]()
//        for index in 0..<allPhotos.count {
//            let image = fetchImage(asset: allPhotos.object(at: index), contentMode: .aspectFit, targetSize: CGSize(width: 80, height: 80))
//            imagesData.append(ImageData(previewImage: image, asset: allPhotos.object(at: index)))
//        }
//        return imagesData
//    }

    class func fetchImage(asset: PHAsset, contentMode: PHImageContentMode, targetSize: CGSize,
                          deliveryMode: PHImageRequestOptionsDeliveryMode = .fastFormat,
                          completion: ((UIImage?) -> ())?) {
        let options = PHImageRequestOptions()
        options.version = .original
        options.deliveryMode = deliveryMode
        options.isSynchronous = false
        PHImageManager.default().requestImage(for: asset, targetSize: targetSize,
                                              contentMode: contentMode, options: options) { img, _ in
                                                completion?(img)
        }
    }

//    class func getListAlbum() -> [Album] {
//        var albums = [Album]()
//        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
//        let topLeverUserCollecions = PHCollectionList.fetchTopLevelUserCollections(with: nil)
//        let allAlbums = [topLeverUserCollecions, smartAlbums]
//        for i in 0 ..< allAlbums.count {
//            let result = allAlbums[i]
//            (result as AnyObject).enumerateObjects { (asset, index, stop) -> () in
//                guard let album = asset as? PHAssetCollection else { return }
//                let assets = PHAsset.fetchKeyAssets(in: album, options: nil)
//                guard let assetss = assets else { return }
//                PHImageManager.default()
//                    .requestImage(for: assetss[assetss.count - 1],
//                                  targetSize: CGSize(width: 70, height: 70),
//                                  contentMode: .aspectFit,
//                                  options: nil, resultHandler: { (result, info) in
//                                    if let image = result,
//                                    let info = info,
//                                    let key = info["PHImageResultIsDegradedKey"] as? Int,
//                                    let title = album.localizedTitle,
//                                    key == 0 {
//                                        let newAlbum = Album(name: title, count: assetss.count, collection: album,
//                                                             latestImage: image)
//                                        albums.append(newAlbum)
//                                    }
//
//                })
//            }
//        }
//        return albums
//    }

    fileprivate class func saveImage(_ image: UIImage, toAlbum album: PHAssetCollection) {
        PHPhotoLibrary.shared().performChanges({
            let changeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
            let enumeration: NSArray = [changeRequest.placeholderForCreatedAsset!]
            albumChangeRequest?.addAssets(enumeration)
        })
    }

    fileprivate class func createAlbum(withName name: String, completion:@escaping () -> Void) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
        }, completionHandler: { success, _ in
            if success {
                completion()
            }
        })
    }

    fileprivate class func album(named: String) -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", named)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album,
                                                                 subtype: .any,
                                                                 options: fetchOptions)
        return collection.firstObject
    }
}
