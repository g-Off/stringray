//
//  MissingCommentLintRule.swift
//  RayGun
//
//  Created by Geoffrey Foster on 2020-02-13.
//

import Foundation
import RayGun

struct DuplicateKeyLintRule: LintRule {
	let info: RuleInfo = RuleInfo(identifier: "duplicate_key", name: "Duplicate Key", description: "", severity: .error)
	
	func scan(table: Table, config: Linter.Config.Rule) throws -> [LintRuleViolation] {
		var violations: [LintRuleViolation] = []
		for (_, localization) in table.localizations {
			var pluralKeys: Set<String> = []
			var singularKeys: Set<String> = []
			localization.all.forEach {
				switch $0.value {
				case .plural:
					if !pluralKeys.insert($0.key).inserted {
						let violation = LintRuleViolation(locale: table.base, location: $0.location, severity: config.severity, reason: "Duplicate Key")
						violations.append(violation)
					}
				case .text:
					if !singularKeys.insert($0.key).inserted {
						let violation = LintRuleViolation(locale: table.base, location: $0.location, severity: config.severity, reason: "Duplicate Key")
						violations.append(violation)
					}
				}
			}
		}
		return violations
	}
	
	func repair(table: Table) throws {
		for (_, localization) in table.localizations {
			var duplicates: Set<LocalizedString> = []
			var pluralKeys: Set<String> = []
			var singularKeys: Set<String> = []
			localization.all.forEach {
				switch $0.value {
				case .plural:
					if !pluralKeys.insert($0.key).inserted {
						duplicates.insert($0)
					}
				case .text:
					if !singularKeys.insert($0.key).inserted {
						duplicates.insert($0)
					}
				}
			}
			localization.remove(duplicates)
		}
	}
}
