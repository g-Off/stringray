//
//  OrphanedLocalizationLintRule.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-07.
//

import Foundation

struct OrphanedLocalizationLintRule: LintRule {
	let info: RuleInfo = RuleInfo(identifier: "orphaned_localization", name: "Orphaned Localization", description: "")
	
	func scan(table: StringsTable, url: URL) throws -> [LintRuleViolation] {
		var violations: [LintRuleViolation] = []
		var entries = table.entries
		entries.removeValue(forKey: table.base)
		let baseEntries = table.baseEntries
		for entry in entries {
			let orphanedEntries = entry.value.subtracting(baseEntries)
			for orphanedEntry in orphanedEntries {
				let file = URL(fileURLWithPath: "\(entry.key).lproj/\(table.name).strings", relativeTo: url)
				guard let line = orphanedEntry.location?.line else { continue }
				let location = LintRuleViolation.Location(file: file, line: line)
				let reason = "Orphaned \(orphanedEntry.key)"
				let violation = LintRuleViolation(locale: entry.key, location: location, severity: .warning, reason: reason)
				violations.append(violation)
			}
		}
		return violations
	}
}
