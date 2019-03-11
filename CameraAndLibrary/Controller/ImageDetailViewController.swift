//
//  ImageDetailViewController.swift
//  CameraAndLibrary
//
//  Created by can.khac.nguyen on 3/1/19.
//  Copyright © 2019 can.khac.nguyen. All rights reserved.
//

import UIKit
import Photos
import FBSDKCoreKit
import FBSDKLoginKit
import FacebookShare
import GoogleSignIn

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
    @IBOutlet weak var backgroundDropdownView: UIView!
    @IBOutlet weak var topBackgroundConstraint: NSLayoutConstraint!
    
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
        backgroundDropdownView.alpha = 0
        topBackgroundConstraint.constant = -backgroundDropdownView.bounds.height
    }

    private func animateShowDropdownView() {
        backgroundDropdownView.alpha = 1
        UIView.animate(withDuration: 1, animations: { [weak self] in
            self?.topBackgroundConstraint.constant = 0
            self?.backgroundDropdownView.layoutIfNeeded()
        }, completion: nil)
    }

    private func animateHideDropdownView() {
        let backgroundHeight = backgroundDropdownView.bounds.height
        UIView.animate(withDuration: 1, animations: { [weak self] in
            self?.backgroundDropdownView.alpha = 0
            self?.topBackgroundConstraint.constant = -backgroundHeight
            self?.backgroundDropdownView.layoutIfNeeded()
            }, completion: nil)
    }

    @objc func handleDoubleTapGesture(_ recognizer: UITapGestureRecognizer) {
        currentZoomLvl.getNextLevel()
        isZooming = currentZoomLvl.rawValue != 1
        let tapPoint = recognizer.location(in: scrollView)
        scrollView.zoomToPoint(zoomPoint: tapPoint, withScale: currentZoomLvl.rawValue, animated: true)
    }
    
    @IBAction func onFacebookShareClicked(_ sender: Any) {
        if !FBSDKAccessToken.currentAccessTokenIsActive() {
            let manager = FBSDKLoginManager()
            manager.logIn(withReadPermissions: ["public_profile"], from: self) { (result, error) in
                if let error = error {
                    // Show alert login error
                    print("facebook login error: \(error)")
                    return
                }
                if let result = result {
                    if result.isCancelled {
                        // Show alert login cancel
                        print("facebook login is canceled")
                        return
                    } else {
                        // Show alert login success
                        print("facebook login is success")
                        return
                    }
                }
            }
        } else {
            guard let image = contentImageView.image else { return }
            let shareContent = PhotoShareContent(photos: [Photo(image: image, userGenerated: true)])
            let shareDialog = ShareDialog(content: shareContent)
            shareDialog.mode = .native
            shareDialog.failsOnInvalidData = true
            shareDialog.completion = { [weak self] result in
                switch result {
                case .success:
                    let alert = UIAlertController(title: "Share", message: "Share success", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(cancelAction)
                    self?.present(alert, animated: true, completion: nil)
                default:
                    let alert = UIAlertController(title: "Share", message: "Share fail", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(cancelAction)
                    self?.present(alert, animated: true, completion: nil)
                }
            }
            try? shareDialog.show()
        }
    }
    @IBAction func onTwitterSharedClicked(_ sender: Any) {
    }
    @IBAction func onGoogleShareClicked(_ sender: Any) {
        GIDSignIn.sharedInstance()?.uiDelegate = self
        GIDSignIn.sharedInstance()?.signIn()
    }
    @IBAction func onDismissButtonClicked(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onShareServiceClicked(_ sender: Any) {
        if topBackgroundConstraint.constant < 0 {
            animateShowDropdownView()
        } else {
            animateHideDropdownView()
        }
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

extension ImageDetailViewController: GIDSignInUIDelegate {
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        print("present")
    }

    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        print("dismiss")
    }
}
