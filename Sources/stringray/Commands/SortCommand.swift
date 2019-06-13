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
		var allLocales: Bool = false
	}
	let command: String = "sort"
	let overview: String = "Sorts the given strings table alphabetically by key."

	private let binder: ArgumentBinder<Arguments>

	init(parser: ArgumentParser) {
		binder = ArgumentBinder<Arguments>()
		let subparser = parser.add(subparser: command, overview: overview)
		let inputFile = subparser.add(positional: "inputFile", kind: PathArgument.self, optional: false, usage: "", completion: .filename)
		let allLocales = subparser.add(option: "--all-locales", shortName: "-a", kind: Bool.self, usage: "Loads all locales under the given base one to be sorted")

		binder.bind(positional: inputFile) { (arguments, inputFile) in
			arguments.inputFile = URL(fileURLWithPath: inputFile.path.asString)
		}
		binder.bind(option: allLocales) { (arguments, allLocales) in
			arguments.allLocales = allLocales
		}
	}

	func run(with arguments: ArgumentParser.Result) throws {
		var commandArgs = Arguments()
		try binder.fill(parseResult: arguments, into: &commandArgs)
		try sort(url: commandArgs.inputFile, allLocales: commandArgs.allLocales)
	}

	private func sort(url: Foundation.URL, allLocales: Bool) throws {
		var options:StringsTableLoader.Options = [.ignoreCached]
		if !allLocales {
			options.insert(.singleLocale)
		}
		let loader = StringsTableLoader(options: options)
		var table = try loader.load(url: url)
		table.sort()
		try loader.write(to: url.resourceDirectory, table: table)
	}
}
