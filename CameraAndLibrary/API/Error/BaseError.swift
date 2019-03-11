//
//  BaseError.swift
//  MyEditor
//
//  Created by Do Hung on 8/28/18.
//  Copyright © 2018 Do Hung. All rights reserved.
//

import Foundation

enum BaseError: Error {
    private struct Constants {
        static let error = "Error"
        static let networkError = "Network Error"
        static let unexpectedError = "Unexpected Error"
        static let redirectionError = "It was transferred to a different URL. I'm sorry for causing you trouble"
        static let clientError = "An error occurred on the application side. Please try again later!"
        static let serverError = "A server error occurred. Please try again later!"
        static let unofficalError = "An error occurred. Please try again later!"
    }
    
    case networkError
    case httpError(httpCode: Int)
    case unexpectedError
    case apiFailure(error: ErrorResponse?)
    
    public var errorMessage: String? {
        switch self {
        case .networkError:
            return Constants.networkError
            
        case .httpError(let code):
            return getHttpErrorMessage(httpCode: code)
            
        case .apiFailure(let error):
            if let error = error {
                return error.statusMessage
            }
            return Constants.error
            
        default:
            return Constants.unexpectedError
        }
    }
    
    private func getHttpErrorMessage(httpCode: Int) -> String? {
        switch HTTPStatusCode(rawValue: httpCode)?.responseType {
        case .redirection?:
            return Constants.redirectionError
            
        case .clientError?:
            return Constants.clientError
            
        case .serverError?:
            return Constants.serverError
            
        default:
            return Constants.unofficalError
        }
    }
}
