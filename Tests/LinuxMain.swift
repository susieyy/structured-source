import XCTest

import StructuredSourceTests

var tests = [XCTestCaseEntry]()
tests += StructuredSourceTests.allTests()
XCTMain(tests)
