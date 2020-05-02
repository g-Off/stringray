//
//  MissingCommentLintRuleTests.swift
//  
//
//  Created by Geoffrey Foster on 2020-02-15.
//

import XCTest
import RayGun
@testable import SillyString

class MissingCommentLintRuleTests: XCTestCase {
	let rule = MissingCommentLintRule()
	
	func testMissingComment() throws {
		let baseLocale = "en"
		let key = "key"
		let english = Localization(name: "Test", locale: baseLocale)
		english.add(key: key, value: "Hi", comment: nil)
		let table = Table(name: "Test", base: baseLocale)
		table.add(localization: english)
		let violations = try rule.scan(table: table, config: .init(severity: rule.info.severity))
		XCTAssertEqual(violations.count, 1)
	}
}
