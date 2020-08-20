# StructuredSource

Porting JavaScript [StructuredSource](https://github.com/Constellation/structured-source) to Swift. 

Provides StructuredSource and functionality for converting range and loc vice versa.

## Installation

Swift Package Manager

Add the following to your Package.swift file's dependencies:

```swift
.package(url: "https://github.com/susieyy/structured-source.git", from: "1.0.8"),
```

## Usage

```swift
let src = StructuredSource("aaa\u{2028}aaaa\u{2029}

XCTAssertEqual(src.positionToIndex(Position(line: 1, column: 2)), Result<Int, OutOfRangeError>.success(2))

XCTAssertEqual(src.indexToPosition(2), Position(line: 1, column: 2))

XCTAssertEqual(src.rangeToLocation(0..<2), Location(start: Position(line: 1, column: 0), end: Position(line: 1, column: 2)))
```

## Note

- Line number starts with 1.
- Column number starts with 0.
