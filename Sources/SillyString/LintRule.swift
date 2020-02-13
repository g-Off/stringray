//
//  LintRule.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-07.
//

import Foundation
import RayGun

public protocol LintRule {
	var info: RuleInfo { get }	
	func scan(table: Table, config: Linter.Config.Rule) throws -> [LintRuleViolation]
	func repair(table: Table) throws
}

public extension LintRule {
	func repair(table: Table) throws {
		// Default version does nothing
	}
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
	public let locale: String
	public let location: Location?
	public let severity: Severity
	public let reason: String
	
	public init(locale: String, location: Location?, severity: Severity, reason: String) {
		self.locale = locale
		self.location = location
		self.severity = severity
		self.reason = reason
	}
}
