# OCAPIClient

A Swift 6 compatible networking client library for making HTTP API requests.

## Requirements

- **Swift 6.0+**
- **Platforms**: iOS 13.0+, tvOS 13.0+, watchOS 8.0+, Linux

## Features

- Async/await based networking with `OCAPIClient`
- Combine publisher support with `OCApiClientPublisher` (Apple platforms only)
- Swift 6 language mode with strict concurrency support
- Cross-platform support (macOS, iOS, tvOS, watchOS, Linux)

## About FoundationNetworking Import

**`import FoundationNetworking`について (About FoundationNetworking import):**

Swift 6でLinux環境でビルドする際、`URLSession`、`URLRequest`などのネットワーク関連型は`FoundationNetworking`モジュールに移動されました。このライブラリはクロスプラットフォーム対応のため、条件付きインポートを使用しています。

In Swift 6 on Linux, networking types like `URLSession` and `URLRequest` have been moved to the `FoundationNetworking` module. This library uses conditional imports to support cross-platform builds:

```swift
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking  // Required for Linux
#endif
```

- **Apple platforms** (macOS, iOS, etc.): Networking types are in `Foundation` - no extra import needed
- **Linux**: Networking types are in `FoundationNetworking` - conditional import required

This is a Swift 6 requirement and not optional for Linux compatibility.
