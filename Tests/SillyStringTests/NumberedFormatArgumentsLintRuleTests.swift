//
//  NumberedFormatArgumentsLintRuleTests.swift
//  
//
//  Created by Geoffrey Foster on 2020-03-18.
//

import XCTest
import RayGun
@testable import SillyString

class NumberedFormatArgumentsLintRuleTests: XCTestCase {
	let rule = NumberedFormatArgumentsLintRule()
	
	func testOrphanedLocalization() throws {
		let baseLocale = "en"
		
		let key = "key"
		let english = Localization(name: "Test", locale: baseLocale)
		english.add(key: key, value: "%@ mentioned you on %@ at %@", comment: "Comment")
		
		let table = Table(name: "Test", base: baseLocale)
		table.add(localization: english)
		
		let violations = try rule.scan(table: table, config: .init(severity: rule.info.severity))
		XCTAssertEqual(violations.count, 1)
	}
}
