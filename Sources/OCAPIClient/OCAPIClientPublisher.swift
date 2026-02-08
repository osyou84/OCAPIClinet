//
//  OCAPIClientPublisher.swift
//  
//
//  Created by Naoya on 2022/03/26.
//

#if canImport(Combine)
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Combine

/// HTTP API client that uses Combine publishers for making network requests
public class OCAPIClientPublisher {
    private let timeoutInterval: TimeInterval
    
    /// Initializes a new API client instance
    /// - Parameter timeoutInterval: The timeout interval for requests in seconds. Defaults to 20 seconds.
    public init(timeoutInterval: TimeInterval = 20) {
        self.timeoutInterval = timeoutInterval
    }
    
    /// Fetches data from the specified request as a Combine publisher
    /// - Parameters:
    ///   - request: The request configuration conforming to OCRequestable
    ///   - session: The URLSession to use. Defaults to URLSession.shared
    /// - Returns: A publisher that emits the response data or an error
    public func fetch(_ request: OCRequestable, session: URLSession = .shared) -> AnyPublisher<Data, OCNetworkError> {
        guard let urlRequest = request.urlRequest else {
            return Fail(error: OCNetworkError.invalidRequest).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: urlRequest)
            .subscribe(on: DispatchQueue.global())
            .mapError { error -> OCNetworkError in
                guard !error.isNetworkError else { return .collectionLost }
                
                return .unknown()
            }
            .flatMap { output -> AnyPublisher<Data, OCNetworkError> in
                guard let response = output.response as? HTTPURLResponse else {
                    return Fail(error: .invalidResponse).eraseToAnyPublisher()
                }
                
                do {
                    let result = try OCResponseHandler.handleResponse(statusCode: response.statusCode, data: output.data)
                    return Future() { $0(.success(result)) }.eraseToAnyPublisher()
                } catch let error as OCNetworkError {
                    return Fail(error: error).eraseToAnyPublisher()
                } catch {
                    return Fail(error: .unknown()).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
}

extension URLSession.DataTaskPublisher.Failure {
    public var isNetworkError: Bool {
        return errorCode == NSURLErrorNotConnectedToInternet || errorCode == NSURLErrorDataNotAllowed
    }
}
#endif
