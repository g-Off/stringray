//
//  LintRule.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-07.
//

import Foundation

protocol LintRule {
	func scan(table: StringsTable, url: URL) -> [LintRuleViolation]
}

enum Severity: String {
	case warning
	case error
}

struct LintRuleViolation {
	struct Location {
		let file: URL
		let line: Int?
	}
	
	let location: Location
	let severity: Severity
	let reason: String
	
	public init(location: Location, severity: Severity, reason: String) {
		self.location = location
		self.severity = severity
		self.reason = reason
	}
}
