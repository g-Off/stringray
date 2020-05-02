//
//  ValidFormatArgumentsLintRuleTests.swift
//  
//
//  Created by Geoffrey Foster on 2020-03-19.
//

import XCTest
import RayGun
@testable import SillyString

class ValidFormatArgumentsLintRuleTests: XCTestCase {
	let rule = ValidFormatArgumentsLintRule()
	
	func testOrphanedLocalization() throws {
		let baseLocale = "en"
		
		let english = Localization(name: "Test", locale: baseLocale)
		english.add(key: "1", value: "%")
		
		let table = Table(name: "Test", base: baseLocale)
		table.add(localization: english)
		
		let violations = try rule.scan(table: table, config: .init(severity: rule.info.severity))
		XCTAssertEqual(violations.count, 1)
	}
}
