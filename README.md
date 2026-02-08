# OCAPIClient

A Swift networking library providing type-safe HTTP API clients with both async/await and Combine support.

## Features

- ✅ **Modern async/await support** - Use Swift concurrency for clean, readable networking code
- ✅ **Combine publisher support** - Integrate seamlessly with Combine-based architectures
- ✅ **Cross-platform** - Works on iOS, macOS, tvOS, watchOS, and Linux
- ✅ **Type-safe requests** - Protocol-based request configuration
- ✅ **Comprehensive error handling** - Detailed error types with localized descriptions
- ✅ **Flexible configuration** - Support for JSON and form-data encoding
- ✅ **Customizable** - Injectable URLSession and configurable timeouts

## Requirements

- Swift 5.5+
- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 8.0+

## Installation

### Swift Package Manager

Add OCAPIClient to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/osyou84/OCAPIClinet.git", from: "1.0.0")
]
```

## Usage

### 1. Define your API request

Implement the `OCRequestable` protocol to define your API endpoints:

```swift
import OCAPIClient

struct GetUserRequest: OCRequestable {
    let userId: Int
    
    var baseURL: String { "https://api.example.com" }
    var path: String { "/users/\(userId)" }
    var method: OCRequestMethod { .get }
    var bodyType: OCRequestBodyType { .json }
    var headers: OCRequestHeaders? = nil
    var parameters: OCRequestParameters? = nil
    var authorization: Bool { true }
}

struct CreateUserRequest: OCRequestable {
    let name: String
    let email: String
    
    var baseURL: String { "https://api.example.com" }
    var path: String { "/users" }
    var method: OCRequestMethod { .post }
    var bodyType: OCRequestBodyType { .json }
    var headers: OCRequestHeaders? = ["Content-Type": "application/json"]
    var parameters: OCRequestParameters? {
        ["name": name, "email": email]
    }
    var authorization: Bool { true }
}
```

### 2. Make requests using async/await

```swift
let client = OCAPIClient(timeoutInterval: 30)

// Fetch data
do {
    let data = try await client.fetch(GetUserRequest(userId: 123))
    let user = try JSONDecoder().decode(User.self, from: data)
    print("User: \(user.name)")
} catch let error as OCNetworkError {
    switch error {
    case .client(.notFound, _):
        print("User not found")
    case .client(.unauthorized, _):
        print("Unauthorized access")
    case .collectionLost:
        print("Network connection lost")
    default:
        print("Error: \(error.localizedDescription)")
    }
}
```

### 3. Make requests using Combine

```swift
import Combine

let client = OCAPIClientPublisher(timeoutInterval: 30)
var cancellables = Set<AnyCancellable>()

client.fetch(GetUserRequest(userId: 123))
    .decode(type: User.self, decoder: JSONDecoder())
    .sink(
        receiveCompletion: { completion in
            switch completion {
            case .finished:
                print("Request completed")
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        },
        receiveValue: { user in
            print("User: \(user.name)")
        }
    )
    .store(in: &cancellables)
```

## Request Configuration

### HTTP Methods

Supported HTTP methods:
- `GET` - Query parameters in URL
- `POST` - Body parameters (JSON or form-data)
- `PUT` - Body parameters (JSON or form-data)
- `PATCH` - Body parameters (JSON or form-data)
- `DELETE` - No body
- `HEAD` - No body

### Body Types

- `.json` - Encodes parameters as JSON
- `.formData` - Encodes parameters as URL-encoded form data

### Headers

```swift
var request = GetUserRequest(userId: 123)
request.updateHeaders([
    "Authorization": "Bearer your-token",
    "Accept": "application/json"
])
```

## Error Handling

### Error Types

- `invalidRequest` - Request configuration is invalid
- `invalidResponse` - Response format is invalid
- `client(ClientError, data)` - 4xx client errors
- `server(ServerError, data)` - 5xx server errors
- `collectionLost` - Network connection lost
- `unknown(message)` - Unknown errors

### Supported HTTP Status Codes

**Client Errors (400-499)**:
- 400 Bad Request
- 401 Unauthorized
- 403 Forbidden
- 404 Not Found
- 408 Request Timeout
- 429 Too Many Requests
- And more...

**Server Errors (500-599)**:
- 500 Internal Server Error
- 502 Bad Gateway
- 503 Service Unavailable
- 504 Gateway Timeout
- And more...

All errors conform to `LocalizedError` for easy display.

## Advanced Usage

### Custom URLSession

```swift
let configuration = URLSessionConfiguration.default
configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
let customSession = URLSession(configuration: configuration)

let data = try await client.fetch(request, session: customSession)
```

### Custom Timeout

```swift
let client = OCAPIClient(timeoutInterval: 60) // 60 seconds timeout
```

## License

[Your License Here]

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
