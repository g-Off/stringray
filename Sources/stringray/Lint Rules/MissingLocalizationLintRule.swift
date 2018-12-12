//
//  MissingLocalizationLintRule.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-07.
//

import Foundation

struct MissingLocalizationLintRule: LintRule {
	let info: RuleInfo = RuleInfo(identifier: "missing_localization", name: "Missing Localization", description: "", severity: .warning)
	
	func scan(table: StringsTable, url: URL, config: Linter.Config.Rule?) throws -> [LintRuleViolation] {
		return scanEntries(table: table, url: url, config: config) + scanDictEntries(table: table, url: url, config: config)
	}
	
	private func scanEntries(table: StringsTable, url: URL, config: Linter.Config.Rule?) -> [LintRuleViolation] {
		var violations: [LintRuleViolation] = []
		var entries = table.entries
		entries.removeValue(forKey: table.base)
		let baseEntries = table.baseEntries
		for entry in entries {
			let missingEntries = baseEntries.subtracting(entry.value)
			for missingEntry in missingEntries {
				let file = URL(fileURLWithPath: "\(entry.key.identifier).lproj/\(table.name).strings", relativeTo: url)
				let location = LintRuleViolation.Location(file: file, line: nil)
				let reason = "Missing \(missingEntry.key)"
				let violation = LintRuleViolation(locale: entry.key, location: location, severity: config?.severity ?? info.severity, reason: reason)
				violations.append(violation)
			}
		}
		return violations
	}
	
	private func scanDictEntries(table: StringsTable, url: URL, config: Linter.Config.Rule?) -> [LintRuleViolation] {
		var violations: [LintRuleViolation] = []
		var dictEntries = table.dictEntries
		dictEntries.removeValue(forKey: table.base)
		let baseDictEntries = table.baseDictEntries
		for dictEntry in dictEntries {
			let missingDictEntries = baseDictEntries.filter { !dictEntry.value.keys.contains($0.key) }
			for missingDictEntry in missingDictEntries {
				let file = URL(fileURLWithPath: "\(dictEntry.key.identifier).lproj/\(table.name).stringsdict", relativeTo: url)
				let location = LintRuleViolation.Location(file: file, line: nil)
				let reason = "Missing \(missingDictEntry.key)"
				let violation = LintRuleViolation(locale: dictEntry.key, location: location, severity: config?.severity ?? info.severity, reason: reason)
				violations.append(violation)
			}
		}
		return violations
	}
}
