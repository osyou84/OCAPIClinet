//
//  OCResponseHandler.swift
//  
//
//  Created by Naoya on 2022/03/26.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Handles HTTP response status codes and converts them to appropriate errors
enum OCResponseHandler {
    /// Validates the HTTP response status code and returns data or throws an error
    /// - Parameters:
    ///   - statusCode: The HTTP status code
    ///   - data: The response data
    /// - Returns: The response data if status code indicates success
    /// - Throws: OCNetworkError based on the status code
    static func handleResponse(statusCode: Int, data: Data) throws -> Data {
        switch statusCode {
        case 200...299:
            return data
        case 400...499:
            guard let clientError = OCNetworkError.ClientError(rawValue: statusCode) else {
                throw OCNetworkError.unknown(message: "\(statusCode)")
            }
            throw OCNetworkError.client(clientError, data: data)
        case 500...599:
            guard let serverError = OCNetworkError.ServerError(rawValue: statusCode) else {
                throw OCNetworkError.unknown(message: "\(statusCode)")
            }
            throw OCNetworkError.server(serverError, data: data)
        default:
            throw OCNetworkError.unknown(message: "\(statusCode)")
        }
    }
}
