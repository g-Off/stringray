//
//  CommandRegistry.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-07.
//

import Foundation
import Utility
import Basic

struct CommandRegistry {
	private let parser: ArgumentParser
	private var commands: [Command] = []
	
	private let versionOption: OptionArgument<Bool>?
	private let version: Version?
	
	init(usage: String, overview: String, version: Version? = nil) {
		self.parser = ArgumentParser(usage: usage, overview: overview)
		self.version = version
		if version != nil {
			self.versionOption = parser.add(option: "--version", shortName: "-v", kind: Bool.self, usage: "Version", completion: nil)
		} else {
			self.versionOption = nil
		}
	}
	
	mutating func register(command: Command.Type) {
		commands.append(command.init(parser: parser))
	}
	
	func run() {
		do {
			let parsedArguments = try parse()
			try process(arguments: parsedArguments)
			exit(EXIT_SUCCESS)
		}
		catch let error as ArgumentParserError {
			print(error.description)
			exit(EXIT_FAILURE)
		}
		catch let error {
			print(error.localizedDescription)
			exit(EXIT_FAILURE)
		}
	}
	
	private func parse() throws -> ArgumentParser.Result {
		let arguments = Array(ProcessInfo.processInfo.arguments.dropFirst())
		return try parser.parse(arguments)
	}
	
	private func process(arguments: ArgumentParser.Result) throws {
		if let versionOption = versionOption, arguments.get(versionOption) == true, let version = version {
			stdoutStream.write("\(version)\n")
			stdoutStream.flush()
			return
		}
		guard let subparser = arguments.subparser(parser),
			let command = commands.first(where: { $0.command == subparser }) else {
				parser.printUsage(on: stdoutStream)
				return
		}
		try command.run(with: arguments)
	}
}
