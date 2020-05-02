//
//  OrphanedLocalizationLintRuleTests.swift
//  
//
//  Created by Geoffrey Foster on 2020-02-15.
//

import XCTest
import RayGun
@testable import SillyString

class OrphanedLocalizationLintRuleTests: XCTestCase {
	let rule = OrphanedLocalizationLintRule()
	
	func testOrphanedLocalization() throws {
		let baseLocale = "fr"
		
		let key = "key"
		let english = Localization(name: "Test", locale: "en")
		english.add(key: key, value: "%1$@ mentioned you on %2$@ at %3$@", comment: "Comment")
		
		let table = Table(name: "Test", base: baseLocale)
		table.add(localization: Localization(name: "Test", locale: baseLocale))
		table.add(localization: english)
		
		let violations = try rule.scan(table: table, config: .init(severity: rule.info.severity))
		XCTAssertEqual(violations.count, 1)
	}
}
