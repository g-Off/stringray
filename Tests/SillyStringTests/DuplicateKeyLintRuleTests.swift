//
//  DuplicateKeyLintRuleTests.swift
//  
//
//  Created by Geoffrey Foster on 2020-02-15.
//

import XCTest
import RayGun
@testable import SillyString

class DuplicateKeyLintRuleTests: XCTestCase {
	let rule = DuplicateKeyLintRule()
	
	func testDuplicateKey() throws {
		let baseLocale = "en"
		let key = "key"
		let english = Localization(name: "Test", locale: baseLocale)
		english.add(key: key, value: "Hi", comment: "Comment")
		english.add(key: key, value: "There", comment: "Comment")
		let table = Table(name: "Test", base: baseLocale)
		table.add(localization: english)
		let violations = try rule.scan(table: table, config: .init(severity: rule.info.severity))
		XCTAssertEqual(violations.count, 1)
	}
}
