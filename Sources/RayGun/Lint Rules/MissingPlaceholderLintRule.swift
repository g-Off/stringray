//
//  MissingPlaceholderLintRule.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-20.
//

import Foundation

struct MissingPlaceholderLintRule: LintRule {
	let info: RuleInfo = RuleInfo(identifier: "missing_placeholder", name: "Missing Placeholder", description: "", severity: .error)
	
	func scan(table: StringsTable, url: Foundation.URL, config: Linter.Config.Rule?) throws -> [LintRuleViolation] {
		var violations: [LintRuleViolation] = []
		var placeholders: [String: [PlaceholderType]] = [:]
		try table.baseEntries.forEach {
			placeholders[$0.key] = try PlaceholderType.orderedPlaceholders(from: $0.value)
		}
		for entry in table.localizedEntries {
			try entry.value.forEach {
				let placeholder = try PlaceholderType.orderedPlaceholders(from: $0.value)
				if let basePlaceholder = placeholders[$0.key], placeholder != basePlaceholder {
					let file = Foundation.URL(fileURLWithPath: "\(entry.key.identifier).lproj/\(table.name).strings", relativeTo: url)
					let line = $0.location?.line
					let location = LintRuleViolation.Location(file: file, line: line)
					let reason = "Mismatched placeholders \($0.key)"
					let violation = LintRuleViolation(locale: entry.key, location: location, severity: config?.severity ?? info.severity, reason: reason)
					violations.append(violation)
				}
			}
		}
		return violations
	}
}
