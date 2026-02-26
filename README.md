# OCAPIClient

[![GitHub release](https://img.shields.io/github/release/osyou84/OCAPIClinet)](https://github.com/osyou84/OCAPIClinet/releases/latest)
[![Swift](https://img.shields.io/badge/Swift-6.0-orange)](https://swift.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue)](https://github.com/osyou84/OCAPIClinet/blob/master/LICENSE)

Swift 製の軽量ネットワーククライアントライブラリです。`async/await` ベースの `OCAPIClient` と、Combine ベースの `OCApiClientPublisher` の2つのインターフェースを提供します。

## 動作環境

- iOS 16+
- tvOS 16+
- watchOS 9+
- macOS 13+
- Swift 6+

## インストール

最新バージョンは上記バッジから確認してください。

### Swift Package Manager

`Package.swift` に以下を追加してください。

```swift
dependencies: [
    .package(url: "https://github.com/osyou84/OCAPIClinet.git", from: "<version>")
]
```

または Xcode の **File > Add Package Dependencies...** からリポジトリ URL を入力してください。

```
https://github.com/osyou84/OCAPIClinet
```

## 使い方

### 1. リクエストの定義

`OCRequestable` プロトコルに準拠した構造体を作成します。

```swift
import OCAPIClient

struct GetUserRequest: OCRequestable {
    var baseURL: String { "https://api.example.com" }
    var path: String { "/users/1" }
    var method: OCRequestMethod { .get }
    var bodyType: OCRequestBodyType { .json }
    var headers: OCRequestHeaders? = ["Content-Type": "application/json"]
    var parameters: OCRequestParameters? { nil }
    var authorization: Bool { false }
}
```

### 2. async/await で使う（OCAPIClient）

```swift
import OCAPIClient

let client = OCAPIClient()

do {
    let data = try await client.fetch(GetUserRequest())
    let user = try JSONDecoder().decode(User.self, from: data)
    print(user)
} catch let error as OCNetworkError {
    switch error {
    case .client(let clientError, _):
        print("クライアントエラー: \(clientError)")
    case .server(let serverError, _):
        print("サーバーエラー: \(serverError)")
    case .collectionLost:
        print("ネットワーク接続が失われました")
    default:
        print("不明なエラー")
    }
}
```

### 3. Combine で使う（OCApiClientPublisher）

```swift
import OCAPIClient
import Combine

var cancellables = Set<AnyCancellable>()
let publisher = OCApiClientPublisher()

publisher.fetch(GetUserRequest())
    .map { try? JSONDecoder().decode(User.self, from: $0) }
    .sink(
        receiveCompletion: { completion in
            if case .failure(let error) = completion {
                print("エラー: \(error)")
            }
        },
        receiveValue: { user in
            print(user)
        }
    )
    .store(in: &cancellables)
```

## OCRequestable プロトコル

| プロパティ | 型 | 説明 |
|---|---|---|
| `baseURL` | `String` | ベース URL |
| `path` | `String` | エンドポイントのパス |
| `method` | `OCRequestMethod` | HTTPメソッド（`.get` / `.post` / `.put` / `.patch` / `.delete` / `.head`）|
| `bodyType` | `OCRequestBodyType` | リクエストボディの形式（`.json` / `.formData`）|
| `headers` | `OCRequestHeaders?` | HTTPヘッダー |
| `parameters` | `OCRequestParameters?` | クエリパラメータ（GET）またはボディ（POST / PUT / PATCH）|
| `authorization` | `Bool` | 認証が必要かどうか |

## エラー

`OCNetworkError` で各種エラーを扱えます。

| ケース | 説明 |
|---|---|
| `.invalidRequest` | URLの生成に失敗 |
| `.invalidResponse` | レスポンスの解析に失敗 |
| `.client(ClientError, data: Data?)` | 4xx クライアントエラー |
| `.server(ServerError, data: Data?)` | 5xx サーバーエラー |
| `.collectionLost` | ネットワーク接続なし |
| `.unknown(message: String?)` | その他のエラー |

## ライセンス

[MIT](https://github.com/osyou84/OCAPIClinet/blob/master/LICENSE)
