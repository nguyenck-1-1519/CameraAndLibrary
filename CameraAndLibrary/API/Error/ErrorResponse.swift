//
//  ErrorResponse.swift
//  MyEditor
//
//  Created by Do Hung on 8/28/18.
//  Copyright © 2018 Do Hung. All rights reserved.
//

import Foundation
import ObjectMapper

class ErrorResponse: Mappable {
    var statusCode: String?
    var statusMessage: String?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        statusCode <- map["status_code"]
        statusMessage <- map["status_message"]
    }
}
