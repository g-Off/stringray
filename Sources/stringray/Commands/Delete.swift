//
//  Delete.swift
//  
//
//  Created by Geoffrey Foster on 2020-03-05.
//

import Foundation
import RayGun
import ArgumentParser
import Files

struct Delete: ParsableCommand {
	static var configuration = CommandConfiguration(abstract: "Copy keys matching the given pattern from one strings table to another.")
	
	@OptionGroup()
	var inputs: Input
	
	@Option(help: "Locale to delete from.\nIf not specified then matching strings from all locales will be deleted.")
	var locale: String?
	
	@Option(help: "Prefix to match against that will be deleted.")
	var prefix: [String]
	
	@Option(help: "Exact string to match against that will be deleted.")
	var exact: [String]
	
	private var matching: [Match] {
		return prefix.map { Match.prefix($0) } + exact.map { Match.exact($0) }
	}
	
	func validate() throws {
		guard !matching.isEmpty else {
			throw ArgumentParser.ValidationError("At least one of prefix or exact must be specified.")
		}
	}
	
	func run() throws {
		let outputs = Output(destination: inputs.source, output: inputs.input)
		if let locale = locale {
			try Operation.delete.perform(
				inputs: inputs,
				outputs: outputs,
				locale: locale,
				matching: matching
			)
		} else {
			let table = try inputs.loadTable()
			try table.localizations.forEach { (locale, localization) in
				try Operation.delete.perform(
					inputs: inputs,
					outputs: outputs,
					locale: locale,
					matching: matching
				)
			}
		}
	}
}
