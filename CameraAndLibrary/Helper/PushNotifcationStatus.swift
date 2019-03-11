//
//  PushNotifcationStatus.swift
//  CameraAndLibrary
//
//  Created by can.khac.nguyen on 3/11/19.
//  Copyright © 2019 can.khac.nguyen. All rights reserved.
//

import Foundation

enum PushNotificationHandleMode {
    case whileAppIsRunning
    case whileBackgroundMode
    case whileAppClosed
    case none

    func getLabelTitle() -> String {
        switch self {
        case .whileAppIsRunning:
            return "Running"
        case .whileBackgroundMode:
            return "Background"
        case .whileAppClosed:
            return "Closed"
        default:
            return "---"
        }
    }
}

protocol PushNotificationStatusDelegate: class {
    func onCurrentStatusChanged(status: PushNotificationHandleMode)
}

class PushNotificationStatus {
    static let shared = PushNotificationStatus()

    weak var delegate: PushNotificationStatusDelegate?
    var current: PushNotificationHandleMode {
        didSet {
            delegate?.onCurrentStatusChanged(status: current)
        }
    }

    init() {
        current = .none
    }
}
