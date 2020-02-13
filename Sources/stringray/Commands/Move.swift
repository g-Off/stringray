//
//  MoveCommand.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-04.
//

import Foundation
import ArgumentParser
import RayGun

struct Move: ParsableCommand {
	static var configuration = CommandConfiguration(abstract: "Moves keys matching the given pattern from one strings table to another.")
	
	@OptionGroup()
	var inputs: Input
	
	@OptionGroup()
	var outputs: Output
	
	@Option(help: "Locale to move to/from.\nIf not specified then matching strings from all locales will be copied to the destination table.")
	var locale: String?
	
	@Option(help: "Prefix to match against that will be moved to the destination table.\nIf not specified then all strings will be moved.")
	var prefix: [String]
	
	@Option(help: "Exact string to match against that will be moved to the destination table.\nIf not specified then all strings will be moved.")
	var exact: [String]
	
	func run() throws {
		let matching = prefix.map { Match.prefix($0) } + exact.map { Match.exact($0) }
		if let locale = locale {
			try Operation.move.perform(
				inputs: inputs,
				outputs: outputs,
				locale: locale,
				matching: matching
			)
		} else {
			let table = try inputs.loadTable()
			try table.localizations.forEach { (locale, localization) in
				try Operation.move.perform(
					inputs: inputs,
					outputs: outputs,
					locale: locale,
					matching: matching
				)
			}
		}
	}
}
