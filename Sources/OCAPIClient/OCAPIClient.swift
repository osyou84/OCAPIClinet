//
//  OCAPIClient.swift
//
//
//  Created by Naoya on 2022/03/26.
//

import Foundation

public final class OCAPIClient: Sendable {
    private let timeoutInterval: TimeInterval

    public init(timeoutInterval: TimeInterval = 20) {
        self.timeoutInterval = timeoutInterval
    }

    public func fetch(_ request: OCRequestable, session: URLSession = .shared) async throws -> Data {
        guard var urlRequest = request.urlRequst else {
            throw OCNetworkError.invalidRequest
        }

        urlRequest.timeoutInterval = timeoutInterval

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch let error as NSError {
            if error.domain == NSURLErrorDomain, error.code == NSURLErrorTimedOut {
                throw OCNetworkError.client(.requestTimeout, data: nil)
            } else if error.code == NSURLErrorNotConnectedToInternet || error.code == NSURLErrorDataNotAllowed {
                throw OCNetworkError.collectionLost
            } else {
                throw OCNetworkError.unknown(message: error.localizedDescription)
            }
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw OCNetworkError.invalidResponse
        }

        let statusCode = httpResponse.statusCode
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
