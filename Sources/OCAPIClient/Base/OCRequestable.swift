//
//  OCRequestable.swift
//  
//
//  Created by Naoya on 2022/03/26.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// HTTP request method types
public enum OCRequestMethod: String {
    case get
    case post
    case put
    case patch
    case delete
    case head
}

/// HTTP request body encoding types
public enum OCRequestBodyType {
    case json
    case formData
}

public typealias OCRequestHeaders = [String: String]
public typealias OCRequestParameters = [String: Any]

/// Protocol defining the requirements for an HTTP request
public protocol OCRequestable {
    /// The base URL for the request (e.g., "https://api.example.com")
    var baseURL: String { get }
    
    /// The path to append to the base URL (e.g., "/users")
    var path: String { get }
    
    /// The HTTP method to use for the request
    var method: OCRequestMethod { get }
    
    /// The encoding type for the request body
    var bodyType: OCRequestBodyType { get }
    
    /// Optional HTTP headers for the request
    var headers: OCRequestHeaders? { get set }
    
    /// Optional parameters for the request (query params for GET, body for POST/PUT/PATCH)
    var parameters: OCRequestParameters? { get }
    
    /// Whether the request requires authorization
    var authorization: Bool { get }
    
    /// Updates the headers for the request
    /// - Parameter headers: The new headers to set
    mutating func updateHeaders(_ headers: OCRequestHeaders)
}

extension OCRequestable {
    public var urlRequest: URLRequest? {
        guard let url = url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue.uppercased()
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        
        return request
    }
    
    private var url: URL? {
        guard var urlComponents = URLComponents(string: baseURL) else {
            return nil
        }
        
        urlComponents.path += path
        urlComponents.queryItems = queryItems
        
        return urlComponents.url
    }
    
    private var queryItems: [URLQueryItem]? {
        guard method == .get, let parameters = parameters else {
            return nil
        }
        
        return parameters.compactMap {
            return URLQueryItem(name: $0.key, value: String(describing: $0.value))
        }
    }
    
    private var body: Data? {
        guard [.post, .put, .patch].contains(method), let parameters = parameters else {
            return nil
        }
        
        switch bodyType {
        case .json:
            return try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        case .formData:
            let urlQueryValueAllowed: CharacterSet = {
                let generalDelimitersToEncode = ":#[]@"
                let subDelimitersToEncode = "!$&'()*+,;="

                var allowed = CharacterSet.urlQueryAllowed
                allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
                return allowed
            }()
            
            return parameters
                .map { key, value in
                    let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: urlQueryValueAllowed) ?? ""
                    let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: urlQueryValueAllowed) ?? ""
                    return escapedKey + "=" + escapedValue
                }
                .joined(separator: "&")
                .data(using: .utf8)
        }
    }
    
    mutating func updateHeaders(_ headers: OCRequestHeaders) {
        self.headers = headers
    }
}
