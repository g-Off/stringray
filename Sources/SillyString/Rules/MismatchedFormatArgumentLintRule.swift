//
//  MismatchedFormatArgumentLintRule.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-20.
//

import Foundation
import RayGun
import PrintfParser

struct MismatchedFormatArgumentLintRule: LintRule {
	let info: RuleInfo = RuleInfo(identifier: "mismatched_format_argument", name: "Mismatched Format Argument", description: "", severity: .error)
	
	func scan(table: Table, config: Linter.Config.Rule) throws -> [LintRuleViolation] {
		var violations: [LintRuleViolation] = []
		var formatSpecs: [String: [Spec]] = [:]
		try table.baseLocalization.strings.forEach { localizedString in
			formatSpecs[localizedString.key] = try localizedString.text.formatSpecifiers()
		}
		
		try table.localizations.forEach { (locale, localization) in
			try localization.strings.forEach { localizedString in
				if let baseSpecs = formatSpecs[localizedString.key] {
					let localizedSpecs = try localizedString.text.formatSpecifiers()
					if !compare(base: baseSpecs, other: localizedSpecs) {
						let reason = "Mismatched placeholders \(localizedString.key)"
						let violation = LintRuleViolation(locale: locale, location: localizedString.location, severity: config.severity, reason: reason)
						violations.append(violation)
					}
				}
			}
		}
		
		return violations
	}
	
	private func compare(base: [Spec], other: [Spec]) -> Bool {
		var baseMap: [Int8?: [Spec]] = [:]
		base.forEach {
			baseMap[$0.mainArgNum, default: []].append($0)
		}
		
		var otherMap: [Int8?: [Spec]] = [:]
		other.forEach {
			otherMap[$0.mainArgNum, default: []].append($0)
		}
		
		return baseMap == otherMap
	}
}
