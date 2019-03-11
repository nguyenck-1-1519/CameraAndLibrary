//
//  UploadImageRequest.swift
//  CameraAndLibrary
//
//  Created by can.khac.nguyen on 3/11/19.
//  Copyright © 2019 can.khac.nguyen. All rights reserved.
//

import UIKit

class UploadImageRequest: BaseRequest {
    required init(folderName name: String, imageFile image: UIImage) {
        let body: [String: Any] = [
            "folder" : name,
            "file" : image
            ]
        let url = URLs.baseUrl + URLs.uploadUrl
        super.init(url: url, requestType: .post, body: body)
    }
}
