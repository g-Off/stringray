//
//  LintRule.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-07.
//

import Foundation

public protocol LintRule {
	var info: RuleInfo { get }
	func scan(table: StringsTable, url: Foundation.URL, config: Linter.Config.Rule?) throws -> [LintRuleViolation]
}

public struct RuleInfo {
	public let identifier: String
	public let name: String
	public let description: String
	public let severity: Severity
}

public enum Severity: String, CustomStringConvertible, Decodable {
	case warning
	case error
	
	public var description: String {
		return rawValue
	}
}

public struct LintRuleViolation {
	public struct Location: CustomStringConvertible {
		public let file: Foundation.URL
		public let line: Int?
		
		public var description: String {
			var path = file.lastPathComponent
			if let line = line {
				path.append(":\(line)")
			}
			return path
		}
	}
	
	public let locale: Locale
	public let location: Location
	public let severity: Severity
	public let reason: String
	
	public init(locale: Locale, location: Location, severity: Severity, reason: String) {
		self.locale = locale
		self.location = location
		self.severity = severity
		self.reason = reason
	}
}
