//
//  OCApiClientPublisher.swift
//
//
//  Created by Naoya on 2022/03/26.
//

import Foundation
import Combine

public final class OCApiClientPublisher: @unchecked Sendable {
    private let timeoutInterval: TimeInterval

    public init(timeoutInterval: TimeInterval = 20) {
        self.timeoutInterval = timeoutInterval
    }

    public func fetch(_ request: OCRequestable, session: URLSession = .shared) -> AnyPublisher<Data, OCNetworkError> {
        guard var urlRequest = request.urlRequst else {
            return Fail(error: OCNetworkError.invalidRequest).eraseToAnyPublisher()
        }

        urlRequest.timeoutInterval = timeoutInterval

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

                let statusCode = response.statusCode
                switch statusCode {
                case 200...299:
                    return Just(output.data)
                        .setFailureType(to: OCNetworkError.self)
                        .eraseToAnyPublisher()
                case 400...499:
                    guard let clientError = OCNetworkError.ClientError(rawValue: statusCode) else {
                        return Fail(error: .unknown(message: "\(statusCode)")).eraseToAnyPublisher()
                    }
                    return Fail(error: .client(clientError, data: output.data)).eraseToAnyPublisher()
                case 500...599:
                    guard let serverError = OCNetworkError.ServerError(rawValue: statusCode) else {
                        return Fail(error: .unknown(message: "\(statusCode)")).eraseToAnyPublisher()
                    }
                    return Fail(error: .server(serverError, data: output.data)).eraseToAnyPublisher()
                default:
                    return Fail(error: .unknown(message: "\(statusCode)")).eraseToAnyPublisher()
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
