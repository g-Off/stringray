//
//  RenameCommand.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-06.
//

import Foundation
import Utility

struct RenameCommand: Command {
	private struct Arguments {
		var inputFile: Foundation.URL!
		var matching: [Match] = []
	}
	
	let command: String = "rename"
	let overview: String = ""
	
	private let binder: ArgumentBinder<Arguments>
	
	init(parser: ArgumentParser) {
		binder = ArgumentBinder<Arguments>()
		let subparser = parser.add(subparser: command, overview: overview)
		
		let inputFile = subparser.add(positional: "inputFile", kind: PathArgument.self, optional: false, usage: "", completion: .filename)
		let prefix = subparser.add(option: "--prefix", shortName: "-p", kind: [String].self, strategy: .oneByOne, usage: "", completion: nil)
		
		binder.bind(positional: inputFile) { (arguments, inputFile) in
			arguments.inputFile = URL(fileURLWithPath: inputFile.path.asString)
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
		try rename(url: commandArgs.inputFile, matching: commandArgs.matching)
	}
	
	private func rename(url: Foundation.URL, matching: [Match]) throws {
		// TODO: implement
	}
}
