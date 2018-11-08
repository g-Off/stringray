//
//  OrphanedLocalizationLintRule.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-07.
//

import Foundation

struct OrphanedLocalizationLintRule: LintRule {
	func scan(table: StringsTable) -> [LintRuleViolation] {
		var violations: [LintRuleViolation] = []
		var entries = table.entries
		entries.removeValue(forKey: table.baseLocale)
		let baseEntries = table.baseEntries
		for entry in entries {
			let orphanedEntries = entry.value.subtracting(baseEntries)
			for orphanedEntry in orphanedEntries {
				let reason = "\(entry.key), \(orphanedEntry.keyedValue.key)"
				violations.append(LintRuleViolation(line: orphanedEntry.keyedValue.line, reason: reason))
			}
		}
		return violations
	}
}
