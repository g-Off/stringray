//
//  Input.swift
//  
//
//  Created by Geoffrey Foster on 2020-02-28.
//

import ArgumentParser
import Files
import RayGun
import Foundation

struct Input: ParsableCommand {
	@Argument(help: "The name of the source strings table.")
	var source: String
	
	@Option(default: Folder.current, help: "Input directory.\nIf not specified then defaults to the current directory.")
	var input: Folder
	
	@Option(help: "Base locale.\nIf not specified then a set of heuristics will be used to attempt to resolve the base.")
	var base: String?
	
	@Option(parsing: .singleValue, help: "Locales to ignore.")
	var ignore: [String]
	
	func loadTable() throws -> Table {
		return try Table(name: source, base: try computedBase(), path: input.path, ignoring: Set(ignore))
	}
	
	func loadLocalization(_ locale: String) throws -> Localization {
		return try Localization(name: source, folder: folder(for: locale))
	}
	
	func folder(for locale: String) throws -> Folder {
		let lproj = "\(locale).lproj"
		return try input.subfolder(named: lproj)
	}
	
	private func computedBase() throws -> String {
		let baseLocale: String
		if let base = base {
			baseLocale = base
		} else if input.containsSubfolder(named: "Base.lproj") {
			baseLocale = "Base"
		} else if let languageCode = Locale.current.languageCode, input.containsSubfolder(named: "\(languageCode).lproj") {
			baseLocale = languageCode
		} else {
			throw ArgumentParser.ValidationError("Base locale could not be inferred.")
		}
		return baseLocale
	}
}
