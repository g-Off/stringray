//
//  LocalizationTests.swift
//  
//
//  Created by Geoffrey Foster on 2020-02-13.
//

import XCTest
@testable import RayGun

class LocalizationTests: XCTestCase {
	func testReplace() {
		let key = "this.that"
		let localization = Localization(name: "Test", locale: "en")
		localization.add(key: "\(key).hi", value: "Hi", comment: "Comment")
		localization.add(key: "\(key).there", value: "There", comment: "Comment")
		
		localization.replace(matches: [.prefix(key)], replacements: ["greet"])
		
		print(localization)
	}
}
