//
//  CopyCommand.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-12-05.
//

import Foundation
import RayGun
import ArgumentParser
import Files

struct Copy: ParsableCommand {
	static var configuration = CommandConfiguration(abstract: "Copy keys matching the given pattern from one strings table to another.")
	
	@OptionGroup()
	var inputs: Input
	
	@OptionGroup()
	var outputs: Output
	
	@Option(help: "Locale to copy to/from.\nIf not specified then matching strings from all locales will be copied to the destination table.")
	var locale: String?
	
	@Option(help: "Prefix to match against that will be copied to the destination table.\nIf not specified then all strings will be copied.")
	var prefix: [String]
	
	@Option(help: "Exact string to match against that will be copied to the destination table.\nIf not specified then all strings will be copied.")
	var exact: [String]
	
	func run() throws {
		let matching = prefix.map { Match.prefix($0) } + exact.map { Match.exact($0) }
		if let locale = locale {
			try Operation.copy.perform(
				inputs: inputs,
				outputs: outputs,
				locale: locale,
				matching: matching
			)
		} else {
			let table = try inputs.loadTable()
			try table.localizations.forEach { (locale, localization) in
				try Operation.copy.perform(
					inputs: inputs,
					outputs: outputs,
					locale: locale,
					matching: matching
				)
			}
		}
	}
}
