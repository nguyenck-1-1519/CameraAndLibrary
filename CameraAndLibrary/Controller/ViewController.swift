//
//  ViewController.swift
//  CameraAndLibrary
//
//  Created by can.khac.nguyen on 2/27/19.
//  Copyright © 2019 can.khac.nguyen. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

enum CaptureType {
    case capture
    case record
}

class ViewController: UIViewController {

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var flashAnimationView: UIView!
    @IBOutlet weak var switchCameraButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var recordingImageView: UIImageView!
    @IBOutlet weak var switchCaptureTypeButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var recordTimerLabel: UILabel!
    @IBOutlet weak var notificationHandledStatusLabel: UILabel!
    
    // variable
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCapturePhotoOutput?
    var videoOutput: AVCaptureMovieFileOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var currentFlashModeSetting: AVCaptureDevice.FlashMode = .off
    var currentCaptureType: CaptureType = .capture
    var isRecording = false
    var videoTemproryPath = ""
    var timer: Timer?

    let thumbnailSize = CGSize(width: (UIScreen.main.bounds.width - 30) / 4, height: (UIScreen.main.bounds.width - 30) / 4)
    var fetchResult: PHFetchResult<PHAsset>? = nil
    var imageManager = PHCachingImageManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        PHPhotoLibrary.requestAuthorization { [weak self] (authorization) in
            switch authorization {
            case .authorized:
                // fetch request all photo
                self?.getAllImageRequest()
            default:
                self?.chechPhotoAuthorization()
            }
        }
        PushNotificationStatus.shared.delegate = self
        configView()
        configCameraView()
    }

    deinit {
        captureSession?.stopRunning()
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

    private func getAllImageRequest() {
        if fetchResult == nil {
            let allPhotosOptions = PHFetchOptions()
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchResult = PHAsset.fetchAssets(with: .image, options: allPhotosOptions)
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
            }
        }
    }

    private func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
    }

    private func configView() {
        flashAnimationView.isHidden = true
        let switchCameraImage = #imageLiteral(resourceName: "SwitchCamButton").withRenderingMode(.alwaysTemplate)
        switchCameraButton.setImage(switchCameraImage, for: .normal)
        switchCameraButton.tintColor = .white
        recordingImageView.isHidden = true
        recordTimerLabel.isHidden = true
    }

    private func configCameraView() {
        PHPhotoLibrary.shared().register(self)
        // configure session
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .high

        // select input device backCam
        guard let backCamera = AVCaptureDevice.default(for: .video) else {
            fatalError("cant get device")
        }
        flashButton.isHidden = !backCamera.hasFlash
        // try to create an AVCaptureDeviceInput - midleman to attch input device with backCam
        do {
            let captureInput = try AVCaptureDeviceInput(device: backCamera)
            stillImageOutput = AVCapturePhotoOutput()
            videoOutput = AVCaptureMovieFileOutput()
            guard let output = stillImageOutput,
                let captureSession = captureSession,
                let videoOutput = videoOutput
                else {
                    return
            }
            if captureSession.canAddInput(captureInput), captureSession.canAddOutput(output),
                captureSession.canAddOutput(videoOutput) {
                // configure for session
                captureSession.beginConfiguration()
                captureSession.addInput(captureInput)
                captureSession.addOutput(output)
                captureSession.addOutput(videoOutput)
                captureSession.commitConfiguration()
                setUpLivePreview()
            }
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }

    private func cameraWithPosition(_ position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession
            .init(deviceTypes: [.builtInWideAngleCamera],
                  mediaType: .video,
                  position: .unspecified)

        for device in deviceDiscoverySession.devices {
            if device.position == position {
                return device
            }
        }
        return nil
    }

    private func setUpLivePreview() {
        guard let captureSession = captureSession else { return }
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = .resizeAspect
        videoPreviewLayer?.connection?.videoOrientation = .portrait
        guard let videoPreviewLayer = videoPreviewLayer else { return }
        cameraView.layer.insertSublayer(videoPreviewLayer, below: controlView.layer)

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
            DispatchQueue.main.async {
                self?.cameraView.layoutIfNeeded()
                videoPreviewLayer.frame = self?.cameraView.bounds ?? .zero
            }
        }
    }

    private func animteFlash() {
        flashAnimationView.isHidden = false
        flashAnimationView.alpha = 1
        captureButton.isEnabled = false
        let originalFrame = flashAnimationView.frame
        let toFrame = previewImageView.convert(previewImageView.frame, to: view)
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.flashAnimationView.frame = toFrame
            self?.flashAnimationView.alpha = 0.2
        }) { [weak self]_ in
            self?.flashAnimationView.frame = originalFrame
            self?.flashAnimationView.isHidden = true
            self?.captureButton.isEnabled = true
        }
    }

    private func animateSwitchCaptureType() {
        captureButton.alpha = 1
        switchCameraButton.alpha = 1
        captureButton.isEnabled = false
        switchCaptureTypeButton.isEnabled = false
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.captureButton.alpha = 0
        }) { [weak self] _ in
            self?.captureButton.isEnabled = true
            self?.captureButton.alpha = 1
            guard let currentCaptureType = self?.currentCaptureType else { return }
            self?.captureButton.setImage(currentCaptureType == .capture ? #imageLiteral(resourceName: "CaptureButton") : #imageLiteral(resourceName: "RecordButton"), for: .normal)
        }
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.switchCaptureTypeButton.alpha = 0
        }) { [weak self] _ in
            self?.switchCaptureTypeButton.isEnabled = true
            self?.switchCaptureTypeButton.alpha = 1
            guard let currentCaptureType = self?.currentCaptureType else { return }
            self?.switchCaptureTypeButton.setImage(currentCaptureType == .capture ? #imageLiteral(resourceName: "RecordButton") : #imageLiteral(resourceName: "CaptureButton"), for: .normal)
        }
    }

    private func chechPhotoAuthorization() -> Bool {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            return true
        default:
            let alertController = UIAlertController(title: "Photo Setting Error",
                                                    message: "You need to setting  authorization to continue using app",
                                                    preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "Setting", style: .default) { _ in
                guard let settingUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingUrl) {
                    UIApplication.shared.open(settingUrl, options: [:], completionHandler: { (success) in
                        print("____ \(success) ___")
                        return
                    })
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { _ in
                return
            }
            alertController.addAction(settingsAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
            return false
        }
    }

    private func startTimer() {
        var count = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.recordTimerLabel.text = Utilities.formatDurationTime(time: count)
            count += 1
        }
    }

    private func stopTimer() {
        if let timer = timer {
            timer.invalidate()
        }
        timer = nil
    }

    @objc func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("save video error \(error)")
        } else {
            print("save video success")
            guard let image = Utilities.videoSnapshot(filePathLocal: videoPath) else { return }
            animteFlash()
            previewImageView.image = image
        }
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            print("save image error \(error.localizedDescription)")
        } else {
            print("save image success")
        }
    }

    // MARK: Handle outlet action
    @IBAction func onCaptureButtonClicked(_ sender: UIButton) {
        if !chechPhotoAuthorization() { return }
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        guard
            let captureSession = captureSession,
            let captureInput = captureSession.inputs[0] as? AVCaptureDeviceInput
            else {
                return
        }
        if captureInput.device.hasFlash {
            settings.flashMode = currentFlashModeSetting
        }
        if currentCaptureType == .capture {
            stillImageOutput?.capturePhoto(with: settings, delegate: self)
        } else {
            guard captureSession.isRunning else {
                return
            }
            if isRecording {
                // update UI
                isRecording = false
                recordingImageView.isHidden = true
                switchCaptureTypeButton.isEnabled = true
                recordTimerLabel.isHidden = true
                stopTimer()
                videoOutput?.stopRecording()
            } else {
                let movieFileOutputConnection = videoOutput?.connection(with: .video)
                movieFileOutputConnection?.videoOrientation = .portrait
                let outputFolder = NSTemporaryDirectory()
                let outputFilePath = ((outputFolder as NSString).appendingPathComponent("mov") as NSString).appendingPathExtension("mov")
                guard let outputfilePath = outputFilePath else { return }
                //update UI
                isRecording = true
                recordingImageView.isHidden = false
                switchCaptureTypeButton.isEnabled = false
                recordTimerLabel.isHidden = false
                startTimer()

                videoTemproryPath = outputfilePath
                videoOutput?.startRecording(to: URL(fileURLWithPath: outputfilePath), recordingDelegate: self)
            }
        }
    }

    @IBAction func onPreviewImageClicked(_ sender: UITapGestureRecognizer) {
        print("tap gesture")
    }

    @IBAction func onSwitchCaptureTypeClicked(_ sender: UIButton) {
        currentCaptureType = currentCaptureType == .capture ? .record : .capture
        animateSwitchCaptureType()
    }

    @IBAction func onSwitchCameraClicked(_ sender: UIButton) {
        guard let captureSession = captureSession else { return }
        let captureInput = captureSession.inputs[0]
        captureSession.removeInput(captureInput)
        var  newCamera = AVCaptureDevice.default(for: .video)
        if let captureInput = captureInput as? AVCaptureDeviceInput, captureInput.device.position == .back {
            UIView.transition(with: cameraView, duration: 0.5, options: .transitionFlipFromLeft,
                              animations: { [weak self] in
                                newCamera = self?.cameraWithPosition(.front)
                }, completion: nil)
        } else {
            UIView.transition(with: cameraView, duration: 0.5, options: .transitionFlipFromRight,
                              animations: { [weak self] in
                                newCamera = self?.cameraWithPosition(.back)
                }, completion: nil)
        }
        do {
            guard let newCamera = newCamera else { return }
            flashButton.isHidden = !newCamera.hasFlash
            try captureSession.addInput(AVCaptureDeviceInput(device: newCamera))
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }

    @IBAction func onFlashButtonClicked(_ sender: UIButton) {
        switch currentFlashModeSetting {
        case .off:
            currentFlashModeSetting = .on
            flashButton.setImage(#imageLiteral(resourceName: "FlashOnButton"), for: .normal)
        case .on:
            currentFlashModeSetting = .auto
            flashButton.setImage(#imageLiteral(resourceName: "FlashAutoButton"), for: .normal)
        case .auto:
            currentFlashModeSetting = .off
            flashButton.setImage(#imageLiteral(resourceName: "FlashOffButton"), for: .normal)
        }
    }
}

extension ViewController: AVCapturePhotoCaptureDelegate {

    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        DispatchQueue.main.async { [weak self] in
            self?.animteFlash()
        }
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        let image = UIImage(data: imageData)
        previewImageView.image = image
        PHPhotoLibrary.shared().performChanges({
            let creationRequest = PHAssetCreationRequest.forAsset()
            creationRequest.addResource(with: .photo, data: imageData, options: nil)
        }) { (success, error) in
            if let error = error {
                print("Fail to save image to photo library \(error)")
            } else {
                print("Success to save image to photo library")
            }
        }
        /* Not recommend by https://developer.apple.com/documentation/avfoundation/cameras_and_media_capture/requesting_authorization_for_media_capture_on_ios
        Because UIImage doesnt support the features and metadata in photo output
        if let image = image {
            DispatchQueue.main.async { [weak self] in
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self?.image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
        */
    }
}

extension ViewController: AVCaptureFileOutputRecordingDelegate {

    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection], error: Error?) {
        isRecording = false
        recordingImageView.isHidden = true
        DispatchQueue.main.async { [weak self] in
            guard let videoTemproryPath = self?.videoTemproryPath else { return }
            UISaveVideoAtPathToSavedPhotosAlbum(videoTemproryPath, self, #selector(self?.video(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }

}

extension ViewController: PHPhotoLibraryChangeObserver {

    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let fetchResult = fetchResult, let changes = changeInstance.changeDetails(for: fetchResult)
            else { return }

        // Change notifications may originate from a background queue.
        // As such, re-dispatch execution to the main queue before acting
        // on the change, so you can update the UI.
        DispatchQueue.main.sync {
            // Hang on to the new fetch result.
            self.fetchResult = changes.fetchResultAfterChanges
            // If we have incremental changes, animate them in the collection view.
            if changes.hasIncrementalChanges {
                guard let collectionView = self.collectionView else { fatalError() }
                // Handle removals, insertions, and moves in a batch update.
                collectionView.performBatchUpdates({
                    if let removed = changes.removedIndexes, !removed.isEmpty {
                        collectionView.deleteItems(at: removed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let inserted = changes.insertedIndexes, !inserted.isEmpty {
                        collectionView.insertItems(at: inserted.map({ IndexPath(item: $0, section: 0) }))
                    }
                    changes.enumerateMoves { fromIndex, toIndex in
                        collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                to: IndexPath(item: toIndex, section: 0))
                    }
                })
                // We are reloading items after the batch update since `PHFetchResultChangeDetails.changedIndexes` refers to
                // items in the *after* state and not the *before* state as expected by `performBatchUpdates(_:completion:)`.
                if let changed = changes.changedIndexes, !changed.isEmpty {
                    collectionView.reloadItems(at: changed.map({ IndexPath(item: $0, section: 0) }))
                }
            } else {
                // Reload the collection view if incremental changes are not available.
                collectionView.reloadData()
            }
            resetCachedAssets()
        }
    }

}
