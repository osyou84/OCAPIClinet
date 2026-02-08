import XCTest
@testable import OCAPIClient

final class OCAPIClientTests: XCTestCase {
    
    // MARK: - OCRequestable Tests
    
    func testURLRequestGeneration() throws {
        var request = MockGetRequest()
        request.updateHeaders(["Authorization": "Bearer token"])
        
        let urlRequest = try XCTUnwrap(request.urlRequest)
        XCTAssertEqual(urlRequest.httpMethod, "GET")
        XCTAssertEqual(urlRequest.allHTTPHeaderFields?["Authorization"], "Bearer token")
        XCTAssertTrue(urlRequest.url?.absoluteString.contains("/test") ?? false)
    }
    
    func testPostRequestWithJSONBody() throws {
        let request = MockPostRequest()
        let urlRequest = try XCTUnwrap(request.urlRequest)
        
        XCTAssertEqual(urlRequest.httpMethod, "POST")
        XCTAssertNotNil(urlRequest.httpBody)
        
        // Verify JSON encoding
        let body = try XCTUnwrap(urlRequest.httpBody)
        let json = try JSONSerialization.jsonObject(with: body) as? [String: Any]
        XCTAssertEqual(json?["key"] as? String, "value")
    }
    
    func testGetRequestWithQueryParameters() throws {
        let request = MockGetRequest()
        let urlRequest = try XCTUnwrap(request.urlRequest)
        
        let url = try XCTUnwrap(urlRequest.url)
        XCTAssertTrue(url.absoluteString.contains("param=value"))
    }
    
    // MARK: - OCNetworkError Tests
    
    func testClientErrorDescription() {
        let error = OCNetworkError.client(.notFound, data: nil)
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("404") ?? false)
    }
    
    func testServerErrorDescription() {
        let error = OCNetworkError.server(.internalServerError, data: nil)
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("500") ?? false)
    }
    
    func testInvalidRequestErrorDescription() {
        let error = OCNetworkError.invalidRequest
        XCTAssertEqual(error.errorDescription, "Invalid request configuration")
    }
    
    func testNetworkLostErrorDescription() {
        let error = OCNetworkError.collectionLost
        XCTAssertEqual(error.errorDescription, "Network connection lost")
    }
    
    // MARK: - OCResponseHandler Tests
    
    func testResponseHandlerSuccess() throws {
        let testData = "test".data(using: .utf8)!
        let result = try OCResponseHandler.handleResponse(statusCode: 200, data: testData)
        XCTAssertEqual(result, testData)
    }
    
    func testResponseHandlerClientError() {
        let testData = Data()
        XCTAssertThrowsError(try OCResponseHandler.handleResponse(statusCode: 404, data: testData)) { error in
            guard case let OCNetworkError.client(clientError, _) = error else {
                XCTFail("Expected client error")
                return
            }
            XCTAssertEqual(clientError, .notFound)
        }
    }
    
    func testResponseHandlerServerError() {
        let testData = Data()
        XCTAssertThrowsError(try OCResponseHandler.handleResponse(statusCode: 500, data: testData)) { error in
            guard case let OCNetworkError.server(serverError, _) = error else {
                XCTFail("Expected server error")
                return
            }
            XCTAssertEqual(serverError, .internalServerError)
        }
    }
    
    func testResponseHandlerUnknownStatusCode() {
        let testData = Data()
        XCTAssertThrowsError(try OCResponseHandler.handleResponse(statusCode: 999, data: testData)) { error in
            guard case OCNetworkError.unknown = error else {
                XCTFail("Expected unknown error")
                return
            }
        }
    }
}

// MARK: - Mock Requests

struct MockGetRequest: OCRequestable {
    var baseURL: String { "https://api.test.com" }
    var path: String { "/test" }
    var method: OCRequestMethod { .get }
    var bodyType: OCRequestBodyType { .json }
    var headers: OCRequestHeaders?
    var parameters: OCRequestParameters? { ["param": "value"] }
    var authorization: Bool { false }
}

struct MockPostRequest: OCRequestable {
    var baseURL: String { "https://api.test.com" }
    var path: String { "/test" }
    var method: OCRequestMethod { .post }
    var bodyType: OCRequestBodyType { .json }
    var headers: OCRequestHeaders?
    var parameters: OCRequestParameters? { ["key": "value"] }
    var authorization: Bool { false }
}
