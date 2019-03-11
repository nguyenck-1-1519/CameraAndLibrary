//
//  BaseResponse.swift
//  CameraAndLibrary
//
//  Created by can.khac.nguyen on 3/11/19.
//  Copyright © 2019 can.khac.nguyen. All rights reserved.
//

import Foundation
import ObjectMapper

class BaseResponse: Mappable {

    var code: Int?

    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        code <- map["code"]
    }
}
