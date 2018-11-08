//
//  MissingLocalizationLintRule.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-07.
//

import Foundation

struct MissingLocalizationLintRule: LintRule {
	func scan(table: StringsTable) -> [LintRuleViolation] {
		var violations: [LintRuleViolation] = []
		var entries = table.entries
		entries.removeValue(forKey: table.baseLocale)
		let baseEntries = table.baseEntries
		for entry in entries {
			let missingEntries = baseEntries.subtracting(entry.value)
			for missingEntry in missingEntries {
				violations.append(LintRuleViolation(reason: "\(entry.key), \(missingEntry.keyedValue.key)"))
			}
		}
		return violations
	}
}
