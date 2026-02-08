//
//  OSNetworkError.swift
//  
//
//  Created by Naoya on 2022/03/26.
//

import Foundation

public enum OCNetworkError: Error {
    case invalidResponse
    case invalidRequest
    case client(ClientError, data: Data?)
    case server(ServerError, data: Data?)
    case collectionLost
    case unknown(message: String? = nil)
}

extension OCNetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid or missing HTTP response"
        case .invalidRequest:
            return "Invalid request configuration"
        case .client(let error, _):
            return "Client error: \(error.localizedDescription)"
        case .server(let error, _):
            return "Server error: \(error.localizedDescription)"
        case .collectionLost:
            return "Network connection lost"
        case .unknown(let message):
            return message ?? "Unknown error occurred"
        }
    }
}

extension OCNetworkError {
    public enum ClientError: Int, Error {
        case badRequest = 400
        case unauthorized = 401
        case forbidden = 403
        case notFound = 404
        case methodNotAllowed = 405
        case proxyAuthenticationRequired = 407
        case requestTimeout = 408
        case conflict = 409
        case gone = 410
        case lengthRequired = 411
        case preconditionFailed = 412
        case payloadTooLarge = 413
        case uriTooLong = 414
        case unsupportedMediaType = 415
        case rangeNotSatisfiable = 416
        case expectationFailed = 417
        case misdirectedRequest = 421
        case tooEarly = 425
        case upgradeRequired = 426
        case preconditionRequired = 428
        case tooManyRequest = 429
        case requestHeaderFieldsTooLarge = 431
        case unavailableForLegalReasons = 451
    }
}

extension OCNetworkError.ClientError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .badRequest: return "Bad Request (400)"
        case .unauthorized: return "Unauthorized (401)"
        case .forbidden: return "Forbidden (403)"
        case .notFound: return "Not Found (404)"
        case .methodNotAllowed: return "Method Not Allowed (405)"
        case .proxyAuthenticationRequired: return "Proxy Authentication Required (407)"
        case .requestTimeout: return "Request Timeout (408)"
        case .conflict: return "Conflict (409)"
        case .gone: return "Gone (410)"
        case .lengthRequired: return "Length Required (411)"
        case .preconditionFailed: return "Precondition Failed (412)"
        case .payloadTooLarge: return "Payload Too Large (413)"
        case .uriTooLong: return "URI Too Long (414)"
        case .unsupportedMediaType: return "Unsupported Media Type (415)"
        case .rangeNotSatisfiable: return "Range Not Satisfiable (416)"
        case .expectationFailed: return "Expectation Failed (417)"
        case .misdirectedRequest: return "Misdirected Request (421)"
        case .tooEarly: return "Too Early (425)"
        case .upgradeRequired: return "Upgrade Required (426)"
        case .preconditionRequired: return "Precondition Required (428)"
        case .tooManyRequest: return "Too Many Requests (429)"
        case .requestHeaderFieldsTooLarge: return "Request Header Fields Too Large (431)"
        case .unavailableForLegalReasons: return "Unavailable For Legal Reasons (451)"
        }
    }
}

extension OCNetworkError {
    public enum ServerError: Int, Error {
        case internalServerError = 500
        case notImplemented = 501
        case badGateway = 502
        case serviceUnavailable = 503
        case gatewayTimeout = 504
        case hTTPVersionNotSupported = 505
        case variantAlsoNegotiates = 506
        case notExtended = 510
        case networkAuthenticationRequired = 511
    }
}

extension OCNetworkError.ServerError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .internalServerError: return "Internal Server Error (500)"
        case .notImplemented: return "Not Implemented (501)"
        case .badGateway: return "Bad Gateway (502)"
        case .serviceUnavailable: return "Service Unavailable (503)"
        case .gatewayTimeout: return "Gateway Timeout (504)"
        case .hTTPVersionNotSupported: return "HTTP Version Not Supported (505)"
        case .variantAlsoNegotiates: return "Variant Also Negotiates (506)"
        case .notExtended: return "Not Extended (510)"
        case .networkAuthenticationRequired: return "Network Authentication Required (511)"
        }
    }
}
