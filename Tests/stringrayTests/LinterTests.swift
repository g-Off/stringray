//
//  LinterTests.swift
//  stringrayTests
//
//  Created by Geoffrey Foster on 2019-02-01.
//

import XCTest
@testable import RayGun

class LinterTests: XCTestCase {
	struct TestReporter: Reporter {
		func generateReport<Target>(for violations: [LintRuleViolation], to outputStream: inout Target) where Target : TextOutputStream {
			
		}
	}
	func testLint() {
		var entries = StringsTable.EntriesType()
		let baseLocale = Locale(identifier: "en")
		let otherLocale = Locale(identifier: "fr")
		let key = "key"
		entries[baseLocale, default: OrderedSet<StringsTable.Entry>()].append(
			StringsTable.Entry(location: nil, comment: nil, key: key, value: "%1$@ mentioned you on %2$@ at %3$@")
		)
		entries[otherLocale, default: OrderedSet<StringsTable.Entry>()].append(
			StringsTable.Entry(location: nil, comment: nil, key: key, value: "%1$@ mentioné youé oné %1$@ até %1$@")
		)
		let table = StringsTable(name: "Test", base: baseLocale, entries: entries)
		let linter = Linter(reporter: TestReporter())
		do {
			try linter.report(on: table, url: URL(fileURLWithPath: "file://does/not/exist"))
		} catch {
			print("hello")
		}
	}
}
