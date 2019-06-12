//
//  Linter.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-19.
//

import Foundation

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
		MissingPlaceholderLintRule(),
		MissingCommentLintRule()
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
	
	private func run(on table: StringsTable, url: Foundation.URL) throws -> [LintRuleViolation] {
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
		
		return try runnableRules.flatMap {
			try $0.scan(table: table, url: url, config: config.rules[$0.info.identifier])
		}
	}
	
	public func report(on table: StringsTable, url: Foundation.URL) throws {
		let violations = try run(on: table, url: url)
		var outputStream = LinterOutputStream(fileHandle: FileHandle.standardOutput)
		reporter.generateReport(for: violations, to: &outputStream)
		if !violations.isEmpty {
			throw Linter.Error(violations)
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
