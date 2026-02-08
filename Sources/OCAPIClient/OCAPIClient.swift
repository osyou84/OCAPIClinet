//
//  OCAPIClient.swift
//
//
//  Created by Naoya on 2022/03/26.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// HTTP API client that uses async/await for making network requests
public class OCAPIClient {
    private let timeoutInterval: TimeInterval
    
    /// Initializes a new API client instance
    /// - Parameter timeoutInterval: The timeout interval for requests in seconds. Defaults to 20 seconds.
    public init(timeoutInterval: TimeInterval = 20) {
        self.timeoutInterval = timeoutInterval
    }

    /// Fetches data from the specified request
    /// - Parameters:
    ///   - request: The request configuration conforming to OCRequestable
    ///   - session: The URLSession to use. Defaults to URLSession.shared
    /// - Returns: The response data
    /// - Throws: OCNetworkError if the request fails
    public func fetch(_ request: OCRequestable, session: URLSession = .shared) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            guard var urlRequest = request.urlRequest else {
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

                do {
                    let result = try OCResponseHandler.handleResponse(statusCode: response.statusCode, data: data)
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
            .resume()
        }
    }
}
