//
//  MissingCommentLintRule.swift
//  RayGun
//
//  Created by Geoffrey Foster on 2019-06-02.
//

import Foundation
import RayGun

struct MissingCommentLintRule: LintRule {
	let info: RuleInfo = RuleInfo(identifier: "missing_comment", name: "Missing Comment", description: "", severity: .error)
	
	func scan(table: Table, config: Linter.Config.Rule) throws -> [LintRuleViolation] {
		var violations: [LintRuleViolation] = []
		for string in table.baseLocalization.strings where string.comment == nil {
			let violation = LintRuleViolation(locale: table.base, location: string.location, severity: config.severity, reason: "Missing comment")
			violations.append(violation)
		}
		return violations
	}
}
