//
//  APIService.swift
//  MyEditor
//
//  Created by Do Hung on 8/28/18.
//  Copyright © 2018 Do Hung. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

struct APIService {
    static let share = APIService()
    
    private var alamofireManager = Alamofire.SessionManager.default
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        alamofireManager = Alamofire.SessionManager(configuration: configuration)
    }
    
    func request<T: Mappable>(input: BaseRequest, completion: @escaping ((T?, BaseError?) -> ())) {
        print("\n------------REQUEST INPUT")
        print("link: %@", input.url)
        print("body: %@", input.body ?? "No Body")
        print("------------ END REQUEST INPUT\n")
        self.alamofireManager.request(input.url, method: input.requestType,
                                             parameters: input.body, encoding: input.encoding)
            .validate(statusCode: 200..<500)
            .responseJSON { response in
                print(response.request?.url ?? "Error")
                print(response)
                switch response.result {
                case .success(let value):
                    guard let statusCode = response.response?.statusCode else {
                        completion(nil, BaseError.unexpectedError)
                        return
                    }
                    if statusCode == 200 {
                        if let object = Mapper<T>().map(JSONObject: value) {
                            completion(object, nil)
                        } else {
                            let json: [String: Any] = ["data": value]
                            if let object = Mapper<T>().map(JSONObject: json) {
                                completion(object, nil)
                            }
                        }
                    } else {
                        guard let object = Mapper<ErrorResponse>().map(JSONObject: value) else {
                            completion(nil, BaseError.httpError(httpCode: statusCode))
                            return
                        }
                        completion(nil, BaseError.apiFailure(error: object))
                    }
                case .failure:
                    completion(nil, BaseError.networkError)
                }
        }
    }
}
