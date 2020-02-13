//
//  LintCommand.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-07.
//

import Foundation
import RayGun
import SillyString
import SwiftyTextTable
import ArgumentParser
import Files
import Yams

struct Lint: ParsableCommand {
	static var configuration = CommandConfiguration(
		abstract: "Checks for warnings or errors on strings tables.",
		subcommands: [Run.self, List.self, Repair.self],
		defaultSubcommand: Run.self
	)
}

extension Lint {
	static func config(_ config: File?) throws -> Linter.Config {
		let linterConfig: Linter.Config
		
		if let config = config {
			let string = try config.readAsString()
			linterConfig = try YAMLDecoder().decode(Linter.Config.self, from: string, userInfo: [:])
		} else {
			linterConfig = Linter.Config()
		}
		return linterConfig
	}
	
	struct Run: ParsableCommand {
		@OptionGroup()
		var inputs: Input
		
		@Option(help: "Configuration file. Defaults to <input>/\(Linter.fileName)")
		var config: File?
		
		func run() throws {
			let reporter: Reporter = ConsoleReporter()
			let linter = Linter(reporter: reporter, config: try Lint.config(config))
			let table = try inputs.loadTable()
			
			var violations: [LintRuleViolation] = []
			do {
				print("Linting: \(table.name)")
				try linter.report(on: table)
			} catch let error as Linter.Error {
				violations.append(contentsOf: error.violations)
			}
			
			if !violations.isEmpty {
				throw Linter.Error(violations)
			}
		}
	}
	
	struct Repair: ParsableCommand {
		static var configuration = CommandConfiguration(
			abstract: "Attempt to repair the table."
		)
		
		@OptionGroup()
		var inputs: Input
		
		@Option(help: "Configuration file. Defaults to <input>/\(Linter.fileName)")
		var config: File?
		
		func run() throws {
			let table = try inputs.loadTable()
			
			let linter = Linter(reporter: NullReporter(), config: try Lint.config(config))
			try linter.repair(table: table)
		}
	}
	
	struct List: ParsableCommand {
		static var configuration = CommandConfiguration(
			abstract: "Lists the available rules and default configuration."
		)
		
		func run() throws {
			let linter = Linter(reporter: ConsoleReporter())
			let rules = linter.rules
			let columns = [
				TextTableColumn(header: "id"),
				TextTableColumn(header: "name"),
				TextTableColumn(header: "description")
			]
			var table = TextTable(columns: columns)
			rules.forEach {
				table.addRow(values:
					[
						$0.info.identifier,
						$0.info.name,
						$0.info.description
					]
				)
			}
			print(table.render())
		}
	}
}

extension Linter.Config {
	public init(url: Foundation.URL) throws {
		let string = try String(contentsOf: url, encoding: .utf8)
		self = try YAMLDecoder().decode(Linter.Config.self, from: string, userInfo: [:])
	}
}
