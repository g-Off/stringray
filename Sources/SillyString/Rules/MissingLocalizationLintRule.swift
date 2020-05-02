//
//  MissingLocalizationLintRule.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-07.
//

import Foundation
import RayGun

struct MissingLocalizationLintRule: LintRule {
	let info: RuleInfo = RuleInfo(identifier: "missing_localization", name: "Missing Localization", description: "", severity: .warning)
	
	func scan(table: Table, config: Linter.Config.Rule) throws -> [LintRuleViolation] {
		var violations: [LintRuleViolation] = []
		let baseKeys = table.baseLocalization.allKeys
		for (locale, localization) in table.localizations where locale != table.base {
			for missingKey in baseKeys.subtracting(localization.allKeys) {
				let location = Location(file: "")
				let reason = "Missing \(missingKey)"
				let violation = LintRuleViolation(locale: locale, location: location, severity: config.severity, reason: reason)
				violations.append(violation)
			}
		}
		return violations
	}
}
