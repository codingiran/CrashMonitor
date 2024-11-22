# CrashMonitor

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2013.0+%20|%20macOS%2010.15+%20|%20tvOS%2013.0+%20|%20watchOS%206.0+-lightgrey.svg)](https://developer.apple.com/swift/)

CrashMonitor is a Swift package that provides powerful crash reporting functionality for Apple platforms. Built on top of KSCrash, it offers a simple and modern Swift API for crash reporting and analysis in your applications.

## Features

- 🔍 Comprehensive crash reporting
- 💫 Support for multiple crash types (Mach exceptions, signals, C++ exceptions, NSExceptions)
- 📱 Cross-platform support (iOS, macOS, tvOS, watchOS)
- 🔄 Async/await API support
- 📊 Customizable report formatting
- 💾 Flexible storage options

## Requirements

- Swift 5.9+
- iOS 13.0+
- macOS 10.15+
- tvOS 13.0+
- watchOS 6.0+

## Installation

### Swift Package Manager

Add CrashMonitor to your project through Xcode's Swift Package Manager:

1. File > Add Packages...
2. Enter the package URL: `https://github.com/codingiran/CrashMonitor.git`
3. Select "Up to Next Major Version" with "0.0.1"

Or add it to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/codingiran/CrashMonitor.git", from: "0.0.1")
]
```

## Usage

### Install KSCrash

```swift
import CrashMonitorCore
import CrashMonitorInstall
 
 do {
    try CrashMonitor.install()
 } catch {
    print("CrashMonitor install failed: \(error)")
 }
```

### Get All Crash Reports

```swift
import CrashMonitorCore
import CrashMonitorReport
 
 Task {  
    do {
        let reports = try await CrashMonitor.allReports()
    } catch {
        print("CrashMonitor get all reports failed: \(error)")
    }
 }
```

## License

CrashMonitor is available under the MIT license. See the [LICENSE](LICENSE) file for details.

## Author

CodingIran@gmail.com

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
