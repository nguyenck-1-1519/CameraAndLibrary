//
//  ImageDetailViewController.swift
//  CameraAndLibrary
//
//  Created by can.khac.nguyen on 3/1/19.
//  Copyright © 2019 can.khac.nguyen. All rights reserved.
//

import UIKit
import Photos

enum ZoomLevel: CGFloat {
    case normal = 1.0
    case medium = 2.0
    case maxxx = 4.0

    mutating func getNextLevel() {
        switch self {
        case .normal:
            self = .medium
        case .medium:
            self = .maxxx
        default:
            self = .normal
        }
    }

    mutating func getCurrentLevel(scale: CGFloat) {
        if scale >= 4.0 {
            self = .maxxx
        } else if scale >= 2.0 {
            self = .medium
        } else {
            self = .normal
        }
    }
}

class ImageDetailViewController: UIViewController {
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!

    var asset: PHAsset!
    var currentZoomLvl: ZoomLevel = .normal
    var originalImageCenter: CGPoint?
    let maxScale: CGFloat = 4.0
    let minScale: CGFloat = 1.0
    var isZooming = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PhotoHelper.fetchImage(asset: asset, contentMode: .aspectFit,
                               targetSize: contentImageView.bounds.size,
                               deliveryMode: .highQualityFormat) { [weak self] img in
            self?.contentImageView.image = img
        }
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapGesture(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapGesture)
//
//        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePingGesture(_:)))
//        view.addGestureRecognizer(pinchGesture)
//
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
//        view.addGestureRecognizer(panGesture)
    }

    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        if isZooming {
            if recognizer.state == .began {
                originalImageCenter = recognizer.view?.center
            } else if recognizer.state == .changed {
                let translation = recognizer.translation(in: self.view)
                let dX = contentImageView.center.x + translation.x
                let dY = contentImageView.center.y + translation.y
                contentImageView.center = CGPoint(x: dX, y: dY)
                recognizer.setTranslation(.zero, in: contentImageView.superview)
            }
        } else {
            return
        }
    }

    @objc func handleDoubleTapGesture(_ recognizer: UITapGestureRecognizer) {
        currentZoomLvl.getNextLevel()
        isZooming = currentZoomLvl.rawValue != 1
        let tapPoint = recognizer.location(in: scrollView)
        scrollView.zoomToPoint(zoomPoint: tapPoint, withScale: currentZoomLvl.rawValue, animated: true)
    }

    @objc func handlePingGesture(_ recognizer: UIPinchGestureRecognizer) {
        if recognizer.state == .began || recognizer.state == .changed {
            let currentScale = contentImageView.frame.size.width / contentImageView.bounds.size.width
            var newScale = currentScale * recognizer.scale
            newScale = newScale >= maxScale ? maxScale : newScale <= minScale ? minScale : newScale
            currentZoomLvl.getCurrentLevel(scale: newScale)
            isZooming = newScale != 1
            contentImageView.transform = CGAffineTransform(scaleX: newScale, y: newScale)
            recognizer.scale = 1
        }
    }

    @IBAction func onDismissButtonClicked(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension ImageDetailViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentImageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        currentZoomLvl.getCurrentLevel(scale: scrollView.zoomScale)
    }
}

extension UIScrollView {

    func zoomToPoint(zoomPoint: CGPoint, withScale scale: CGFloat, animated: Bool) {
        //translate the zoom point to relative to the content rect
        let newZoomPoint = CGPoint(x: zoomPoint.x / self.zoomScale, y: zoomPoint.y / self.zoomScale )

        //derive the size of the region to zoom to
        let zoomSize = CGSize(width: self.bounds.size.width / scale, height: self.bounds.size.height / scale)

        //offset the zoom rect so the actual zoom point is in the middle of the rectangle
        let zoomRect = CGRect(x: newZoomPoint.x - zoomSize.width / 2.0,
                              y: newZoomPoint.y - zoomSize.height / 2.0,
                              width: zoomSize.width,
                              height: zoomSize.height)

        //apply the resize
        self.zoom(to: zoomRect, animated: true)

    }

}
