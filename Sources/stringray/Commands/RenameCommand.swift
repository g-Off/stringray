//
//  RenameCommand.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-06.
//

import Foundation
import CommandRegistry
import Basic
import Utility
import RayGun

struct RenameCommand: Command {
	private struct Arguments {
		var inputFile: Foundation.URL!
		var matching: [Match] = []
		var replacements: [String] = []
	}
	
	let command: String = "rename"
	let overview: String = "Renames a key with another key."
	
	private let binder: ArgumentBinder<Arguments>
	
	init(parser: ArgumentParser) {
		binder = ArgumentBinder<Arguments>()
		let subparser = parser.add(subparser: command, overview: overview)
		
		let inputFile = subparser.add(positional: "inputFile", kind: PathArgument.self, optional: false, usage: "", completion: .filename)
		let prefix = subparser.add(option: "--prefix", shortName: "-p", kind: [String].self, strategy: .oneByOne, usage: "", completion: nil)
		let replacement = subparser.add(option: "--replacement", shortName: "-r", kind: [String].self, strategy: .oneByOne, usage: "", completion: nil)
		
		binder.bind(positional: inputFile) { (arguments, inputFile) in
			arguments.inputFile = URL(fileURLWithPath: inputFile.path.asString)
		}
		binder.bind(option: prefix) { (arguments, matching) in
			arguments.matching = matching.map {
				return .prefix($0)
			}
		}
		binder.bind(option: replacement) { (arguments, replacements) in
			arguments.replacements = replacements
		}
	}
	
	func run(with arguments: ArgumentParser.Result) throws {
		var commandArgs = Arguments()
		try binder.fill(parseResult: arguments, into: &commandArgs)
		try rename(url: commandArgs.inputFile, matching: commandArgs.matching, replacements: commandArgs.replacements)
	}
	
	private func rename(url: Foundation.URL, matching: [Match], replacements replacementStrings: [String]) throws {
		let loader = StringsTableLoader()
		var table = try loader.load(url: url)
		table.replace(matches: matching, replacements: replacementStrings)
		try loader.write(to: url.resourceDirectory, table: table)
	}
}
