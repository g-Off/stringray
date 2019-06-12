//
//  MissingCommentLintRule.swift
//  RayGun
//
//  Created by Geoffrey Foster on 2019-06-02.
//

import Foundation

struct MissingCommentLintRule: LintRule {
	let info: RuleInfo = RuleInfo(identifier: "missing_comment", name: "Missing Comment", description: "", severity: .error)
	
	func scan(table: StringsTable, url: Foundation.URL, config: Linter.Config.Rule?) throws -> [LintRuleViolation] {
		var violations: [LintRuleViolation] = []
		let file = Foundation.URL(fileURLWithPath: "\(table.base.identifier).lproj/\(table.name).strings", relativeTo: url)
		for entry in table.baseEntries where entry.comment == nil {
			let line = entry.location?.line
			let location = LintRuleViolation.Location(file: file, line: line)
			let reason = "Mismatched placeholders \(entry.key)"
			let violation = LintRuleViolation(locale: table.base, location: location, severity: config?.severity ?? info.severity, reason: reason)
			violations.append(violation)
		}
		return violations
	}
}
