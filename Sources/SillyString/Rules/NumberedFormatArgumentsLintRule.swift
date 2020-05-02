//
//  NumberedFormatArgumentsLintRule.swift
//  
//
//  Created by Geoffrey Foster on 2020-03-18.
//

import Foundation
import RayGun
import PrintfParser

struct NumberedFormatArgumentsLintRule: LintRule {
	let info: RuleInfo = RuleInfo(identifier: "numbered_format_argument", name: "Numbered Format Arguments", description: "Validates that any localized string with more than one format argument includes numeric positions.", severity: .warning)
	
	func scan(table: Table, config: Linter.Config.Rule) throws -> [LintRuleViolation] {
		var violations: [LintRuleViolation] = []
		var formatSpecs: [String: [Spec]] = [:]
		try table.baseLocalization.strings.forEach { localizedString in
			formatSpecs[localizedString.key] = try localizedString.text.formatSpecifiers()
		}
		
		table.localizations.forEach { (locale, localization) in
			localization.all.forEach { localizedString in
				guard let specs = try? localizedString.text.formatSpecifiers() else { return }
				guard specs.count > 1 else { return }
				let missingSpecs = specs.filter { $0.mainArgNum == nil && !$0.flags.contains(.externalSpec) }
				if !missingSpecs.isEmpty {
					let reason = "Missing numbered positions in format string for key: \(localizedString.key)"
					let violation = LintRuleViolation(locale: locale, location: localizedString.location, severity: config.severity, reason: reason)
					violations.append(violation)
				}
			}
		}
		
		return violations
	}
}
