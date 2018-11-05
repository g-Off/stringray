//
//  SortCommand.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-04.
//

import Foundation
import Utility

struct SortCommand: Command {
	private struct Arguments {
		var inputFile: Foundation.URL!
	}
	let command: String = "sort"
	let overview: String = "Sorts the keys in the given strings table."
	
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
		try save(localization: try localization(for: url) ?? Localization(url: url), options: [.writeFile, .writeCache, .sortedKeys])
	}
}
//class SortCommand: MutatingCommand, Command {
//	let name: String = "sort"
//	
//	let param = Parameter()
//	

//	
//	var shortDescription: String {
//		return "Sorts the strings by key in alphabetic ascending order."
//	}
//}
