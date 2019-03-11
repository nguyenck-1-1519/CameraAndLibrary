//
//  BaseRequest.swift
//  MyEditor
//
//  Created by Do Hung on 8/28/18.
//  Copyright © 2018 Do Hung. All rights reserved.
//

import Foundation
import Alamofire

struct URLs {
    static let baseUrl = "http://192.168.15.71:8800/"
    static let uploadUrl = "upload.php"
}

class BaseRequest: NSObject {
    var url = ""
    var requestType = Alamofire.HTTPMethod.get
    var body: [String: Any]?
    
    init(url: String) {
        super.init()
        self.url = url
    }
    
    init(url: String, requestType: Alamofire.HTTPMethod) {
        super.init()
        self.url = url
        self.requestType = requestType
    }
    
    init(url: String, requestType: Alamofire.HTTPMethod, body: [String: Any]?) {
        super.init()
        self.url = url
        self.requestType = requestType
        self.body = body
    }
    
    var encoding: ParameterEncoding {
        switch requestType {
        case .get:
            return URLEncoding.default
        default:
            return JSONEncoding.default
        }
    }
}
