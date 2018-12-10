//
//  MoveCommand.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-04.
//

import Foundation
import Utility
import CommandRegistry

struct MoveCommand: Command {
	private struct Arguments {
		var inputFile: Foundation.URL!
		var outputFile: Foundation.URL!
		var matching: [Match] = []
	}
	let command: String = "move"
	let overview: String = "Moves keys matching the given pattern from one strings table to another."
	
	private let binder: ArgumentBinder<Arguments>
	
	init(parser: ArgumentParser) {
		binder = ArgumentBinder<Arguments>()
		let subparser = parser.add(subparser: command, overview: overview)
		
		let inputFile = subparser.add(positional: "inputFile", kind: PathArgument.self, optional: false, usage: "", completion: .filename)
		let outputFile = subparser.add(positional: "outputFile", kind: PathArgument.self, optional: false, usage: "", completion: .filename)
		let prefix = subparser.add(option: "--prefix", shortName: "-p", kind: [String].self, strategy: .oneByOne, usage: "", completion: nil)
		
		binder.bind(positional: inputFile) { (arguments, inputFile) in
			arguments.inputFile = URL(fileURLWithPath: inputFile.path.asString)
		}
		binder.bind(positional: outputFile) { (arguments, outputFile) in
			arguments.outputFile = URL(fileURLWithPath: outputFile.path.asString)
		}
		binder.bind(option: prefix) { (arguments, matching) in
			arguments.matching = matching.map {
				return .prefix($0)
			}
		}
	}
	
	func run(with arguments: ArgumentParser.Result) throws {
		var commandArgs = Arguments()
		try binder.fill(parseResult: arguments, into: &commandArgs)
		try move(from: commandArgs.inputFile, to: commandArgs.outputFile, matching: commandArgs.matching)
	}
	
	private func move(from: Foundation.URL, to: Foundation.URL, matching: [Match]) throws {
		let loader = StringsTableLoader()
		var fromTable = try loader.load(url: from)
		var toTable = try loader.load(url: to)
		
		let filteredTable = fromTable.withKeys(matching: matching)
		toTable.addEntries(from: filteredTable)
		fromTable.removeEntries(from: filteredTable)
		try write(to: to.resourceDirectory, table: toTable)
		try write(to: from.resourceDirectory, table: fromTable)
	}
}
