import XCTest
@testable import StructuredSource

final class StructuredSourceTests: XCTestCase {
    func testStructuredSource() {

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
