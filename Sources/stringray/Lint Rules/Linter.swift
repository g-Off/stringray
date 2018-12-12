//
//  Linter.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-19.
//

import Foundation
import Yams

struct Linter {
	struct Config: Decodable {
		struct Rule: Decodable {
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
		
		init() {
			self.included = []
			self.excluded = []
			self.rules = [:]
		}
		
		init(url: URL) throws {
			let string = try String(contentsOf: url, encoding: .utf8)
			self = try YAMLDecoder().decode(Config.self, from: string, userInfo: [:])
		}
		
		init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			self.included = try container.decodeIfPresent([String].self, forKey: .included) ?? []
			self.excluded = try container.decodeIfPresent([String].self, forKey: .excluded) ?? []
			self.rules = try container.decodeIfPresent([String: Rule].self, forKey: .rules) ?? [:]
		}
	}
	
	static let fileName = ".stringray.yml"
	
	static let allRules: [LintRule] = [
		MissingLocalizationLintRule(),
		OrphanedLocalizationLintRule(),
		MissingPlaceholderLintRule()
	]
	
	private enum LintError: Swift.Error {
		case violations
	}
	
	let rules: [LintRule]
	private let reporter: Reporter
	private let config: Config
	
	init(rules: [LintRule] = Linter.allRules, reporter: Reporter = ConsoleReporter(), config: Config = Config()) {
		self.rules = rules
		self.reporter = reporter
		self.config = config
	}
	
	private func run(on table: StringsTable, url: URL) throws -> [LintRuleViolation] {
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
	
	func report(on table: StringsTable, url: URL) throws {
		let violations = try run(on: table, url: url)
		var outputStream = LinterOutputStream(fileHandle: FileHandle.standardOutput)
		reporter.generateReport(for: violations, to: &outputStream)
		if !violations.isEmpty {
			throw LintError.violations
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
