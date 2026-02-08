//
//  OCRequestable.swift
//  
//
//  Created by Naoya on 2022/03/26.
//

import Foundation

public enum OCRequestMethod: String {
    case get
    case post
    case put
    case patch
    case delete
    case head
}

public enum OCRequestBodyType {
    case json
    case formData
}

public typealias OCRequestHeaders = [String: String]
public typealias OCRequestParameters = [String: Any]

public protocol OCRequestable {
    var baseURL: String { get }
    var path: String { get }
    var method: OCRequestMethod { get }
    var bodyType: OCRequestBodyType { get }
    var headers: OCRequestHeaders? { get set }
    var parameters: OCRequestParameters? { get }
    var authorization: Bool { get }
    
    mutating func updateHeaders(_ headers: OCRequestHeaders)
}

extension OCRequestable {
    public var urlRequst: URLRequest? {
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
