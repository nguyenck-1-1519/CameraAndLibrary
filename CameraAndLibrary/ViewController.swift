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
    // variable
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCapturePhotoOutput?
    var videoOutput: AVCaptureMovieFileOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var currentFlashModeSetting: AVCaptureDevice.FlashMode = .off
    var currentCaptureType: CaptureType = .capture
    var isRecording = false
    var listImage = [ImageData]()

    override func viewDidLoad() {
        super.viewDidLoad()
        listImage = PhotoHelper.getAllAssets()
        configView()
        configCameraView()
    }

    deinit {
        captureSession?.stopRunning()
    }

    private func configView() {
        flashAnimationView.isHidden = true
        let switchCameraImage = #imageLiteral(resourceName: "SwitchCamButton").withRenderingMode(.alwaysTemplate)
        switchCameraButton.setImage(switchCameraImage, for: .normal)
        switchCameraButton.tintColor = .white
    }

    private func configCameraView() {
        // configure session
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .high

        // select input device backCam
        guard let backCamera = AVCaptureDevice.default(for: .video) else {
            fatalError("cant get device")
        }
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
                captureSession.addInput(captureInput)
                captureSession.addOutput(output)
                captureSession.addOutput(videoOutput)
                setUpLivePreview()
            }
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }

    private func cameraWithPosition(_ position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let deviceDescoverySession = AVCaptureDevice.DiscoverySession
            .init(deviceTypes: [.builtInWideAngleCamera],
                  mediaType: .video,
                  position: .unspecified)

        for device in deviceDescoverySession.devices {
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

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            print("save error \(error.localizedDescription)")
        } else {
            print("save success")
        }
    }

    // MARK: Handle outlet action
    @IBAction func onCaptureButtonClicked(_ sender: UIButton) {
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
            if isRecording {
                isRecording = false
                videoOutput?.stopRecording()
            } else {
                isRecording = true
                let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                let fileUrl = paths[0].appendingPathExtension("output.mov")
                try? FileManager.default.removeItem(at: fileUrl)
                videoOutput?.startRecording(to: fileUrl, recordingDelegate: self)
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
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        animteFlash()
        guard let imageData = photo.fileDataRepresentation() else { return }
        let image = UIImage(data: imageData)
        previewImageView.image = image
        if let image = image {
            DispatchQueue.main.async {
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
    }
}

extension ViewController: AVCaptureFileOutputRecordingDelegate {

    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection], error: Error?) {
        isRecording = false
        print("abc xyz su`")
    }

}
