//
//  Linter.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-19.
//

import Foundation
import Yams

struct Linter {
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
	let reporter: Reporter
	
	init(rules: [LintRule] = Linter.allRules, reporter: Reporter = ConsoleReporter()) {
		self.rules = rules
		self.reporter = reporter
	}
	
	init(excluded: Set<String> = []) {
		let rules = Linter.allRules.filter {
			!excluded.contains($0.info.identifier)
		}
		self.init(rules: rules)
	}
	
	init(path: String = Linter.fileName, rootPath: String? = nil) throws {
		let rootURL = URL(fileURLWithPath: rootPath ?? FileManager.default.currentDirectoryPath, isDirectory: true)
		let fullPathURL = URL(fileURLWithPath: path, relativeTo: rootURL)
		let yamlString = try String(contentsOf: fullPathURL, encoding: .utf8)
		let dict = try Yams.load(yaml: yamlString) as? [String: Any]
		let excluded = dict?["excluded"] as? [String] ?? []
		self.init(excluded: Set(excluded))
	}
	
	private func run(on table: StringsTable, url: URL) throws -> [LintRuleViolation] {
		return try rules.flatMap {
			try $0.scan(table: table, url: url)
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
