//
//  Utilities.swift
//  CameraAndLibrary
//
//  Created by can.khac.nguyen on 3/6/19.
//  Copyright © 2019 can.khac.nguyen. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class Utilities {

    private struct UtilsConstant {
        static let countTimeFormat = "%02d:%02d"
        static let countTimeFormatWithHour = "%02d:%02d:%02d"
        static let secondsPerHour = 3600
        static let secondsPerMinute = 60
        static let milisecondsPerSecond = 1000
    }

    static func formatDurationTime(time: Int) -> String {
        var tmpTime = time
        let hours = tmpTime / UtilsConstant.secondsPerHour
        tmpTime -= hours * UtilsConstant.secondsPerHour
        let minutes = tmpTime / UtilsConstant.secondsPerMinute
        tmpTime -= minutes * UtilsConstant.secondsPerMinute
        let seconds = tmpTime
        if hours <= 0 {
            return String(format: UtilsConstant.countTimeFormat, minutes, seconds)
        } else {
            return String(format: UtilsConstant.countTimeFormatWithHour, hours, minutes, seconds)
        }
    }

    static func videoSnapshot(filePathLocal: String) -> UIImage? {

        let vidURL = NSURL(fileURLWithPath:filePathLocal as String)
        let asset = AVURLAsset(url: vidURL as URL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true

        let timestamp = CMTime(seconds: 1, preferredTimescale: 60)

        do {
            let imageRef = try generator.copyCGImage(at: timestamp, actualTime: nil)
            return UIImage(cgImage: imageRef)
        }
        catch let error as NSError
        {
            print("Image generation failed with error \(error)")
            return nil
        }
    }
}
