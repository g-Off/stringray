//
//  ValidFormatArgumentsLintRule.swift
//  
//
//  Created by Geoffrey Foster on 2020-03-19.
//

import Foundation
import RayGun
import PrintfParser

struct ValidFormatArgumentsLintRule: LintRule {
	let info: RuleInfo = RuleInfo(identifier: "valid_format_argument", name: "Valid Format Arguments", description: "Validates that all format arguments are valid.", severity: .error)
	
	func scan(table: Table, config: Linter.Config.Rule) throws -> [LintRuleViolation] {
		var violations: [LintRuleViolation] = []
		
		table.localizations.forEach { (locale, localization) in
			localization.all.forEach { localizedString in
				do {
					_ = try localizedString.text.formatSpecifiers()
				} catch {
					let reason = "Invalid format argumeent for key: \(localizedString.key)"
					let violation = LintRuleViolation(locale: locale, location: localizedString.location, severity: config.severity, reason: reason)
					violations.append(violation)
				}
			}
		}
		
		return violations
	}
}
