//
//  Linter.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-19.
//

import Foundation
import RayGun

public struct Linter {
	public struct Config: Decodable {
		public struct Rule: Decodable {
			let severity: Severity
		}
		let included: [String]
		let excluded: [String]
		let rules: [String: Rule]
		
		private enum CodingKeys: String, CodingKey {
			case included
			case excluded
			case rules
		}
		
		public init() {
			self.included = []
			self.excluded = []
			self.rules = [:]
		}
		
		public init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			self.included = try container.decodeIfPresent([String].self, forKey: .included) ?? []
			self.excluded = try container.decodeIfPresent([String].self, forKey: .excluded) ?? []
			self.rules = try container.decodeIfPresent([String: Rule].self, forKey: .rules) ?? [:]
		}
	}
	
	public static let fileName = ".stringray.yml"
	
	public static let allRules: [LintRule] = [
		MissingLocalizationLintRule(),
		OrphanedLocalizationLintRule(),
		DuplicateKeyLintRule(),
		MissingCommentLintRule(),
		// Format arguments
		ValidFormatArgumentsLintRule(),
		MismatchedFormatArgumentLintRule(),
		NumberedFormatArgumentsLintRule()
	]
	
	public struct Error: LocalizedError {
		public private(set) var violations: [LintRuleViolation]
		
		public init(_ violations: [LintRuleViolation]) {
			self.violations = violations
		}
		
		public var errorDescription: String? {
			let errorCount = violations.filter { $0.severity == .error }.count
			let warningCount = violations.filter { $0.severity == .warning }.count
			return "Encountered \(errorCount) errors and \(warningCount) warnings."
		}
	}
	
	public let rules: [LintRule]
	private let reporter: Reporter
	private let config: Config
	
	public init(rules: [LintRule] = Linter.allRules, reporter: Reporter, config: Config = Config()) {
		self.rules = rules
		self.reporter = reporter
		self.config = config
	}
	
	private var enabledRules: [LintRule] {
		var runnableRules = self.rules
		
		let includedRules = Set(config.included)
		if !includedRules.isEmpty {
			runnableRules.removeAll { (rule) -> Bool in
				!includedRules.contains(rule.info.identifier)
			}
		}
		
		let excludedRules = Set(config.excluded)
		runnableRules.removeAll { (rule) -> Bool in
			excludedRules.contains(rule.info.identifier)
		}
		return runnableRules
	}
	
	private func run(on table: Table) throws -> [LintRuleViolation] {
		return try enabledRules.flatMap { rule in
			try rule.scan(table: table, config: config.rules[rule.info.identifier] ?? Linter.Config.Rule(severity: rule.info.severity))
		}
	}
	
	public func report(on table: Table) throws {
		var outputStream = LinterOutputStream(fileHandle: FileHandle.standardOutput)
		try enabledRules.forEach { rule in
			let violations = try rule.scan(table: table, config: config.rules[rule.info.identifier] ?? Linter.Config.Rule(severity: rule.info.severity))
			if !violations.isEmpty {
				reporter.generateReport(for: rule.info, violations: violations, to: &outputStream)
			}
		}
	}
	
	public func repair(table: Table) throws {
		try enabledRules.forEach { rule in
			try rule.repair(table: table)
		}
	}
}

private struct LinterOutputStream: TextOutputStream {
	private let fileHandle: FileHandle
	
	init(fileHandle: FileHandle) {
		self.fileHandle = fileHandle
	}
	
	mutating func write(_ string: String) {
		guard let data = string.appending("\n").data(using: .utf8) else { return }
		fileHandle.write(data)
	}
}
