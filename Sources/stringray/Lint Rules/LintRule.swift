//
//  LintRule.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-07.
//

import Foundation

protocol LintRule {
	var info: RuleInfo { get }
	func scan(table: StringsTable, url: URL, config: Linter.Config.Rule?) throws -> [LintRuleViolation]
}

struct RuleInfo {
	let identifier: String
	let name: String
	let description: String
	let severity: Severity
}

enum Severity: String, CustomStringConvertible, Decodable {
	case warning
	case error
	
	var description: String {
		return rawValue
	}
}

struct LintRuleViolation {
	struct Location: CustomStringConvertible {
		let file: URL
		let line: Int?
		
		var description: String {
			var path = file.lastPathComponent
			if let line = line {
				path.append(":\(line)")
			}
			return path
		}
	}
	
	let locale: Locale
	let location: Location
	let severity: Severity
	let reason: String
	
	public init(locale: Locale, location: Location, severity: Severity, reason: String) {
		self.locale = locale
		self.location = location
		self.severity = severity
		self.reason = reason
	}
}
