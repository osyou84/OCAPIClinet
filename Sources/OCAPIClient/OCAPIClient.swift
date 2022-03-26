//
//  OCAPIClient.swift
//
//
//  Created by Naoya on 2022/03/26.
//

import Foundation

public class OCAPIClient {
    private let timeoutInterval: TimeInterval
    
    public init(timeoutInterval: TimeInterval = 20) {
        self.timeoutInterval = timeoutInterval
    }

    public func fetch(_ request: OCRequestable, session: URLSession = .shared) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            guard var urlRequest = request.urlRequst else {
                return continuation.resume(throwing: OCNetworkError.invalidRequest)
            }
            
            urlRequest.timeoutInterval = timeoutInterval
            
            session.dataTask(with: urlRequest) { data, response, error in
                if let error = error as NSError? {
                    if error.domain == NSURLErrorDomain, error.code == NSURLErrorTimedOut {
                        return continuation.resume(throwing: OCNetworkError.client(.requestTimeout, data: nil))
                    } else if error.code == NSURLErrorNotConnectedToInternet || error.code == NSURLErrorDataNotAllowed {
                        return continuation.resume(throwing: OCNetworkError.collectionLost)
                    } else {
                        return continuation.resume(throwing: OCNetworkError.unknown(message: error.localizedDescription))
                    }
                }
                
                guard let data = data, let response = response as? HTTPURLResponse else {
                    return continuation.resume(throwing: OCNetworkError.invalidResponse)
                }

                let statusCode: Int = response.statusCode
                switch response.statusCode {
                case 200...299:
                    continuation.resume(returning: data)
                case 400...499:
                    guard let clientError = OCNetworkError.ClientError(rawValue: statusCode) else {
                        return continuation.resume(throwing: OCNetworkError.unknown(message: "\(statusCode)"))
                    }
                    
                    return continuation.resume(throwing: OCNetworkError.client(clientError, data: data))
                case 500...599:
                    guard let serverError = OCNetworkError.ServerError(rawValue: statusCode) else {
                        return continuation.resume(throwing: OCNetworkError.unknown(message: "\(statusCode)"))
                    }
                    
                    return continuation.resume(throwing: OCNetworkError.server(serverError, data: data))
                default:
                    return continuation.resume(throwing: OCNetworkError.unknown(message: "\(statusCode)"))
                }
            }
            .resume()
        }
    }
}
