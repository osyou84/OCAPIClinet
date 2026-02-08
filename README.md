# OCAPIClient

Swift製のシンプルで使いやすいAPIクライアントライブラリです。

## 概要

OCAPIClientは、iOSアプリケーションでHTTP APIリクエストを簡単に行うためのSwiftパッケージです。async/awaitとCombineの両方をサポートし、包括的なエラーハンドリングを提供します。

## 特徴

- ✅ **async/await サポート** - モダンなSwift concurrencyに対応
- ✅ **Combine サポート** - Reactive programmingに対応
- ✅ **包括的なエラーハンドリング** - HTTPステータスコードに基づいた詳細なエラー型
- ✅ **カスタマイズ可能** - タイムアウト、ヘッダー、リクエストボディタイプの設定が可能
- ✅ **軽量** - 外部依存なし
- ✅ **マルチプラットフォーム** - iOS 13+、tvOS 13+、watchOS 8+に対応

## インストール

### Swift Package Manager

`Package.swift`ファイルに以下を追加してください：

```swift
dependencies: [
    .package(url: "https://github.com/osyou84/OCAPIClinet.git", from: "0.0.2")
]
```

または、Xcodeで以下の手順でパッケージを追加できます：
1. File → Add Package Dependencies...
2. `https://github.com/osyou84/OCAPIClinet.git` を入力
3. 適切なバージョンを選択

## 使用方法

### 1. リクエストの定義

まず、`OCRequestable`プロトコルに準拠した構造体を作成します：

```swift
import OCAPIClient

struct GetUserRequest: OCRequestable {
    var baseURL: String = "https://api.example.com"
    var path: String = "/users/1"
    var method: OCRequestMethod = .get
    var bodyType: OCRequestBodyType = .json
    var headers: OCRequestHeaders? = ["Content-Type": "application/json"]
    var parameters: OCRequestParameters? = nil
    var authorization: Bool = false
}
```

### 2. async/awaitでのリクエスト実行

```swift
import OCAPIClient

let client = OCAPIClient(timeoutInterval: 20)
let request = GetUserRequest()

do {
    let data = try await client.fetch(request)
    // データの処理
    let user = try JSONDecoder().decode(User.self, from: data)
    print(user)
} catch let error as OCNetworkError {
    // エラーハンドリング
    switch error {
    case .client(let clientError, let data):
        print("クライアントエラー: \(clientError)")
    case .server(let serverError, let data):
        print("サーバーエラー: \(serverError)")
    case .collectionLost:
        print("ネットワーク接続なし")
    case .invalidRequest:
        print("無効なリクエスト")
    case .invalidResponse:
        print("無効なレスポンス")
    case .unknown(let message):
        print("不明なエラー: \(message ?? "")")
    }
}
```

### 3. Combineでのリクエスト実行

```swift
import OCAPIClient
import Combine

let client = OCApiClientPublisher(timeoutInterval: 20)
let request = GetUserRequest()

var cancellables = Set<AnyCancellable>()

client.fetch(request)
    .decode(type: User.self, decoder: JSONDecoder())
    .receive(on: DispatchQueue.main)
    .sink(
        receiveCompletion: { completion in
            switch completion {
            case .finished:
                print("完了")
            case .failure(let error):
                print("エラー: \(error)")
            }
        },
        receiveValue: { user in
            print(user)
        }
    )
    .store(in: &cancellables)
```

### POSTリクエストの例

```swift
struct CreateUserRequest: OCRequestable {
    var baseURL: String = "https://api.example.com"
    var path: String = "/users"
    var method: OCRequestMethod = .post
    var bodyType: OCRequestBodyType = .json
    var headers: OCRequestHeaders? = ["Content-Type": "application/json"]
    var parameters: OCRequestParameters?
    var authorization: Bool = true
    
    init(name: String, email: String) {
        self.parameters = [
            "name": name,
            "email": email
        ]
    }
}

// 使用例
let request = CreateUserRequest(name: "太郎", email: "taro@example.com")
let data = try await client.fetch(request)
```

## サポートされるHTTPメソッド

- GET
- POST
- PUT
- PATCH
- DELETE
- HEAD

## リクエストボディタイプ

- `.json` - JSON形式
- `.formData` - URLエンコードされたフォームデータ

## エラータイプ

OCAPIClientは以下のエラータイプを提供します：

### クライアントエラー (400系)
- `badRequest` (400)
- `unauthorized` (401)
- `forbidden` (403)
- `notFound` (404)
- `methodNotAllowed` (405)
- `requestTimeout` (408)
- `tooManyRequest` (429)
- その他多数のHTTPクライアントエラー

### サーバーエラー (500系)
- `internalServerError` (500)
- `notImplemented` (501)
- `badGateway` (502)
- `serviceUnavailable` (503)
- `gatewayTimeout` (504)
- その他のHTTPサーバーエラー

### その他のエラー
- `invalidRequest` - 無効なリクエスト
- `invalidResponse` - 無効なレスポンス
- `collectionLost` - ネットワーク接続なし
- `unknown` - 不明なエラー

## 動作環境

- iOS 13.0+
- tvOS 13.0+
- watchOS 8.0+
- Swift 5.5+

## ライセンス

このプロジェクトのライセンス情報については、リポジトリをご確認ください。

## 作者

Naoya

## 貢献

プルリクエストを歓迎します。大きな変更の場合は、まずissueを開いて変更内容を議論してください。
