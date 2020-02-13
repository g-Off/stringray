//
//  Output.swift
//
//
//  Created by Geoffrey Foster on 2020-03-04.
//

import ArgumentParser
import Files
import RayGun
import Foundation

struct Output: ParsableCommand {
	@Argument(help: "The name of the destination strings table.")
	var destination: String
	
	@Option(default: Folder.current, help: "Output directory.\nIf not specified then defaults to the current directory.")
	var output: Folder
	
	init() {}
	
	init(destination: String, output: Folder) {
		self.destination = destination
		self.output = output
	}
	
	func loadLocalization(_ locale: String) throws -> Localization {
		let outputFolder = try folder(for: locale)
		return try Localization(name: destination, folder: outputFolder)
	}
	
	func folder(for locale: String) throws -> Folder {
		let lproj = "\(locale).lproj"
		return try output.createSubfolderIfNeeded(at: lproj)
	}
}
