import XCTest

import stringrayTests

var tests = [XCTestCaseEntry]()
tests += stringrayTests.allTests()
XCTMain(tests)