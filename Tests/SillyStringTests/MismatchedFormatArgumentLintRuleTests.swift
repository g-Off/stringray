//
//  MismatchedFormatArgumentLintRuleTests.swift
//  
//
//  Created by Geoffrey Foster on 2020-02-15.
//

import XCTest
import RayGun
@testable import SillyString

class MismatchedFormatArgumentLintRuleTests: XCTestCase {
	let rule = MismatchedFormatArgumentLintRule()
	
	func testMissingLocalization() throws {
		let baseLocale = "en"
		
		let key = "key"
		let english = Localization(name: "Test", locale: baseLocale)
		english.add(key: key, value: "%1$@ mentioned you on %2$@ at %3$@", comment: "Comment")
		let french = Localization(name: "Test", locale: "fr")
		french.add(key: key, value: "%1$@ mentioned you on %2$@", comment: "Comment")
		
		let table = Table(name: "Test", base: baseLocale)
		table.add(localization: english)
		table.add(localization: french)
		
		let violations = try rule.scan(table: table, config: .init(severity: rule.info.severity))
		XCTAssertEqual(violations.count, 1)
	}
}
