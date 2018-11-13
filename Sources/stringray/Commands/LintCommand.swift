//
//  LintCommand.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-07.
//

import Foundation
import Utility

struct LintCommand: Command {
	private struct Arguments {
		var inputFile: Foundation.URL!
	}
	
	let command: String = "lint"
	let overview: String = ""
	private var rules: [LintRule] = [
		MissingLocalizationLintRule(),
		OrphanedLocalizationLintRule()
	]
	
	private let binder: ArgumentBinder<Arguments>
	
	init(parser: ArgumentParser) {
		binder = ArgumentBinder<Arguments>()
		let subparser = parser.add(subparser: command, overview: overview)
		
		let inputFile = subparser.add(positional: "inputFile", kind: PathArgument.self, optional: false, usage: "", completion: .filename)
		
		binder.bind(positional: inputFile) { (arguments, inputFile) in
			arguments.inputFile = URL(fileURLWithPath: inputFile.path.asString)
		}
	}
	
	func run(with arguments: ArgumentParser.Result) throws {
		var commandArgs = Arguments()
		try binder.fill(parseResult: arguments, into: &commandArgs)
		try lint(url: commandArgs.inputFile)
	}
	
	private func lint(url: Foundation.URL) throws {
		let tableForLinting = try StringsTable(url: url)
		for rule in rules {
			let violations = rule.scan(table: tableForLinting, url: url.resourceDirectory)
			for violation in violations {
				print(violation.reason)
			}
		}
	}
}
