//
//  MissingLocalizationLintRule.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-07.
//

import Foundation

struct MissingLocalizationLintRule: LintRule {
	let info: RuleInfo = RuleInfo(identifier: "missing_localization", name: "Missing Localization", description: "")
	
	func scan(table: StringsTable, url: URL) throws -> [LintRuleViolation] {
		return scanEntries(table: table, url: url) + scanDictEntries(table: table, url: url)
	}
	
	private func scanEntries(table: StringsTable, url: URL) -> [LintRuleViolation] {
		var violations: [LintRuleViolation] = []
		var entries = table.entries
		entries.removeValue(forKey: table.base)
		let baseEntries = table.baseEntries
		for entry in entries {
			let missingEntries = baseEntries.subtracting(entry.value)
			for missingEntry in missingEntries {
				let file = URL(fileURLWithPath: "\(entry.key).lproj/\(table.name).strings", relativeTo: url)
				let location = LintRuleViolation.Location(file: file, line: nil)
				let reason = "Missing \(missingEntry.key)"
				let violation = LintRuleViolation(locale: entry.key, location: location, severity: .warning, reason: reason)
				violations.append(violation)
			}
		}
		return violations
	}
	
	private func scanDictEntries(table: StringsTable, url: URL) -> [LintRuleViolation] {
		var violations: [LintRuleViolation] = []
		var dictEntries = table.dictEntries
		dictEntries.removeValue(forKey: table.base)
		let baseDictEntries = table.baseDictEntries
		for dictEntry in dictEntries {
			let missingDictEntries = baseDictEntries.filter { !dictEntry.value.keys.contains($0.key) }
			for missingDictEntry in missingDictEntries {
				let file = URL(fileURLWithPath: "\(dictEntry.key).lproj/\(table.name).stringsdict", relativeTo: url)
				let location = LintRuleViolation.Location(file: file, line: nil)
				let reason = "Missing \(missingDictEntry.key)"
				let violation = LintRuleViolation(locale: dictEntry.key, location: location, severity: .warning, reason: reason)
				violations.append(violation)
			}
		}
		return violations
	}
}
