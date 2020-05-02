//
//  SortCommand.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-04.
//

import Foundation
import RayGun
import ArgumentParser
import Files

struct Sort: ParsableCommand {
	static var configuration = CommandConfiguration(abstract: "Sorts the given strings table alphabetically by key.")
	
	@OptionGroup()
	var inputs: Input
	
	@Option(help: "Locale to sort\nIf not specified then strings from all locales will be sorted.")
	var locale: String?
	
	func run() throws {
		if let locale = locale {
			let localization = try inputs.loadLocalization(locale)
			try sort(localization: localization)
		} else {
			let table = try inputs.loadTable()
			try table.localizations.forEach { (key, localization) in
				try sort(localization: localization)
			}
		}
	}
	
	private func sort(localization: Localization) throws {
		localization.sort()
		try localization.write(to: inputs.input)
	}
}
