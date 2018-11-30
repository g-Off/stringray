//
//  LintCommand.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-07.
//

import Foundation
import Utility
import Basic
import SwiftyTextTable

struct LintCommand: Command {
	private struct Arguments {
		var inputFile: [AbsolutePath] = []
		var listRules: Bool = false
	}
	
	let command: String = "lint"
	let overview: String = "Checks for warnings or errors on the given strings table."
	
	private let binder: ArgumentBinder<Arguments>
	
	init(parser: ArgumentParser) {
		binder = ArgumentBinder<Arguments>()
		let subparser = parser.add(subparser: command, overview: overview)
		
		let filesUsage = "Specify a list of file paths to the string files to run lint on; If omitted, this will default to the current folder"
		let files = subparser.add(positional: "files", kind: [PathArgument].self, optional: true, usage: filesUsage, completion: .filename)
		binder.bind(positional: files) { (arguments, files) in
			arguments.inputFile = files.map { $0.path }
		}
		
		let listRules = subparser.add(option: "--list", shortName: "-l", kind: Bool.self, usage: "List available rules and default configuration", completion: .none)
		binder.bind(option: listRules) { (arguments, listRules) in
			arguments.listRules = listRules
		}
	}
	
	func run(with arguments: ArgumentParser.Result) throws {
		var commandArgs = Arguments()
		try binder.fill(parseResult: arguments, into: &commandArgs)
		
		if commandArgs.listRules {
			listRules()
			return
		}
		
		if commandArgs.inputFile.isEmpty {
			commandArgs.inputFile = [AbsolutePath(FileManager.default.currentDirectoryPath)]
		}
		try lint(files: commandArgs.inputFile)
		
	}
	
	private func listRules() {
		let linter = Linter(excluded: [])
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
	
	private func lint(files: [AbsolutePath]) throws {
		var loader = StringsTableLoader()
		loader.options = [.lineNumbers]
		let linter = Linter(excluded: [])
		
		try files.forEach {
			let url = URL(fileURLWithPath: $0.asString)
			print("Linting: \(url.path)")
			
			var isDirectory: ObjCBool = false
			let fileExists = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
			if fileExists && !isDirectory.boolValue {
				let table = try loader.load(url: url)
				try linter.report(on: table, url: url)
			} else {
				print("Skipping: \(url.path) | this path is a directory or the file does not exist.")
			}
		}
	}
}
