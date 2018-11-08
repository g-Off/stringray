//
//  LintRule.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-07.
//

import Foundation

protocol LintRule {
	func scan(table: StringsTable) -> [LintRuleViolation]
}

struct LintRuleViolation {
	let line: Int?
	let reason: String
	
	init(line: Int? = nil, reason: String) {
		self.line = line
		self.reason = reason
	}
}
