//
//  SortCommand.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-04.
//

import Foundation
import RayGun
import CommandRegistry
import Basic
import Utility

struct SortCommand: Command {
	private struct Arguments {
		var inputFile: Foundation.URL!
	}
	let command: String = "sort"
	let overview: String = "Sorts the given strings table alphabetically by key."

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
		try sort(url: commandArgs.inputFile)
	}

	private func sort(url: Foundation.URL) throws {
		let loader = StringsTableLoader()
		var table = try loader.load(url: url)
		table.sort()
		try loader.write(to: url.resourceDirectory, table: table)
	}
}
