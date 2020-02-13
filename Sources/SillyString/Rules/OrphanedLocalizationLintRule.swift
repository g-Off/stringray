//
//  OrphanedLocalizationLintRule.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-07.
//

import Foundation
import RayGun

struct OrphanedLocalizationLintRule: LintRule {
	let info: RuleInfo = RuleInfo(identifier: "orphaned_localization", name: "Orphaned Localization", description: "", severity: .warning)
	
	func scan(table: Table, config: Linter.Config.Rule) throws -> [LintRuleViolation] {
		var violations: [LintRuleViolation] = []
		let baseKeys = table.baseLocalization.allKeys
		for (locale, localization) in table.localizations where locale != table.base {
			for orphanKey in localization.allKeys.subtracting(baseKeys) {
				let location = Location(file: "")
				let reason = "Orphaned \(orphanKey)"
				let violation = LintRuleViolation(locale: locale, location: location, severity: config.severity, reason: reason)
				violations.append(violation)
			}
		}
		return violations
	}
	
	func repair(table: Table) throws {
		let baseKeys = table.baseLocalization.allKeys
		for (locale, localization) in table.localizations where locale != table.base {
			let orphanKeys = localization.allKeys.subtracting(baseKeys)
			localization.removeAll { orphanKeys.contains($0.key) }
		}
		try table.save()
	}
}
