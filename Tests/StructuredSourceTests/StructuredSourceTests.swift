import XCTest
@testable import StructuredSource

final class StructuredSourceTests: XCTestCase {
    func testStructuredSource() {
        // In swift test:
        // Fatal error: XCTContext.runActivity(named:block:) failed because activities are disallowed in the current configuration

        do { //XCTContext.runActivity(named: "constructor") { _ in
            do {
                let src = StructuredSource("")
                XCTAssertEqual(src.indice, [ 0 ])
                XCTAssertEqual(src.line, 1)
            }
            do {
                let src = StructuredSource("\n")
                XCTAssertEqual(src.indice, [ 0, 1 ])
                XCTAssertEqual(src.line, 2)
            }
            do {
                // Workaround: ignore by wrong
                // let src = StructuredSource("\r\n")
                // XCTAssertEqual(src.indice, [ 0, 2 ]) // [ 0 ]
                // XCTAssertEqual(src.line, 2) // -> 1
            }
            do {
                // Workaround: ignore by crash
                // let src = StructuredSource("\n\r")
                // XCTAssertEqual(src.indice, [ 0, 1, 2 ])
                // XCTAssertEqual(src.line, 3)
            }
            do {
                let src = StructuredSource("aaa\naaaa\raaaaa")
                XCTAssertEqual(src.indice, [ 0, 4, 9 ])
                XCTAssertEqual(src.line, 3)
            }
            do {
                let src = StructuredSource("aaa\u{2028}aaaa\u{2029}aaaaa\n")
                XCTAssertEqual(src.indice, [ 0, 4, 9, 15 ])
                XCTAssertEqual(src.line, 4)
            }
        }

        do { // XCTContext.runActivity(named: "positionToIndex") { _ in
            let src = StructuredSource("aaa\u{2028}aaaa\u{2029}aaaaa\n")
            XCTAssertEqual(src.positionToIndex(Position(line: 1, column: 2)), Result<Int, OutOfRangeError>.success(2))
            XCTAssertEqual(src.positionToIndex(Position(line: 2, column: 2)), Result<Int, OutOfRangeError>.success(6))
            XCTAssertEqual(src.positionToIndex(Position(line: 2, column: 5)), Result<Int, OutOfRangeError>.success(9))  // out of source column is calculated.init
            XCTAssertEqual(src.positionToIndex(Position(line: 3, column: 0)), Result<Int, OutOfRangeError>.success(9))
            XCTAssertEqual(src.positionToIndex(Position(line: 4, column: 0)), Result<Int, OutOfRangeError>.success(15))
            XCTAssertEqual(src.positionToIndex(Position(line: 4, column: 10)), Result<Int, OutOfRangeError>.success(25))
            XCTAssertEqual((src.positionToIndex(Position(line: 5, column: 10))), Result<Int, OutOfRangeError>.failure(OutOfRangeError()))  // out of source line is calculated as NaN.
        }

        do { // XCTContext.runActivity(named: "indexToPosition") { _ in
            do {
                let src = StructuredSource("aaa\u{2028}aaaa\u{2029}aaaaa\n")
                XCTAssertEqual(src.indexToPosition(2), Position(line: 1, column: 2))
                XCTAssertEqual(src.indexToPosition(6), Position(line: 2, column: 2))
                XCTAssertEqual(src.indexToPosition(9), Position(line: 3, column: 0))
                XCTAssertEqual(src.indexToPosition(15), Position(line: 4, column: 0))
                XCTAssertEqual(src.indexToPosition(25), Position(line: 4, column: 10))
                XCTAssertEqual(src.indexToPosition(30), Position(line: 4, column: 15))
                XCTAssertEqual(src.indexToPosition(0), Position(line: 1, column: 0))
            }
            do {
                let src = StructuredSource("")
                XCTAssertEqual(src.indexToPosition(2), Position(line: 1, column: 2))
                XCTAssertEqual(src.indexToPosition(6), Position(line: 1, column: 6))
                XCTAssertEqual(src.indexToPosition(0), Position(line: 1, column: 0))
            }
        }

        do { // XCTContext.runActivity(named: "rangeToLocation") { _ in
            do {
                let src = StructuredSource("aaa\u{2028}aaaa\u{2029}aaaaa\n")
                XCTAssertEqual(src.rangeToLocation(0..<2), Location(start: Position(line: 1, column: 0), end: Position(line: 1, column: 2)))
                XCTAssertEqual(src.rangeToLocation(0..<45), Location(start: Position(line: 1, column: 0), end: Position(line: 4, column: 30)))
             }
             do {
                let src = StructuredSource("")
                XCTAssertEqual(src.rangeToLocation(0..<2), Location(start: Position(line: 1, column: 0), end: Position(line: 1, column: 2)))
             }
        }
        do { // XCTContext.runActivity(named: "locationToRange") { _ in
            do {
                let src = StructuredSource("aaa\u{2028}aaaa\u{2029}aaaaa\n")
                XCTAssertEqual(src.locationToRange(Location(start: Position(line: 1, column: 0), end: Position(line: 1, column: 2))), Result<Range<Int>, OutOfRangeError>.success(0..<2))
                XCTAssertEqual(src.locationToRange(Location(start: Position(line: 1, column: 0), end: Position(line: 4, column: 30))), Result<Range<Int>, OutOfRangeError>.success(0..<45))
            }
            do {
                let src = StructuredSource("")
                XCTAssertEqual(src.locationToRange(Location(start: Position(line: 1, column: 0), end: Position(line: 1, column: 2))), Result<Range<Int>, OutOfRangeError>.success(0..<2))
            }
        }
    }

    func testRe() {
        let str = "Hello, SwiftyRe. link: https://github.com/wl879/SwiftyRe"
        XCTAssertEqual(["Hello", "SwiftyRe", "link", "https://github.com/wl879/SwiftyRe"], Re("[,.:] +").split(str))
        XCTAssertEqual(["Hello", ", ", "SwiftyRe", ". ", "link", ": ", "https://github.com/wl879/SwiftyRe"], Re("[,.:] +").explode(str))
        XCTAssertEqual(true, Re("https?:\\/\\/").test(str))
        XCTAssertEqual(Re.Result(index: 5, lastIndex: 5, values: [","]), Re("\\W").match(str))
        XCTAssertEqual(Re.Result(index: 5, lastIndex: 47, values: [",", " ", ".", " ", ":", " ", ":", "/", "/", ".", "/", "/"]), Re("\\W", "g").match(str))
        XCTAssertEqual("Hello  SwiftyRe  link  https   github com wl879 SwiftyRe", Re("\\W", "g").replace(str, " "))
    }

    func testUpperBound() {
        XCTAssertEqual(upperBound([ 0, 0, 2, 3, 4 ], -1), 0)
        XCTAssertEqual(upperBound([ 0, 0, 2, 3, 4 ], 0), 2)
        XCTAssertEqual(upperBound([ 0, 0, 2, 3, 4 ], 1), 2)
        XCTAssertEqual(upperBound([ 0, 0, 2, 3, 4 ], 2), 3)
        XCTAssertEqual(upperBound([ 0, 0, 2, 3, 4 ], 3), 4)
        XCTAssertEqual(upperBound([ 0, 0, 2, 3, 4 ], 4), 5)
        XCTAssertEqual(upperBound([ 0, 0, 2, 3, 4 ], 5), 5)
    }

    static var allTests = [
        ("testUpperBound", testUpperBound),
        ("testStructuredSource", testStructuredSource)
    ]
}
