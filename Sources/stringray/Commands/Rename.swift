//
//  RenameCommand.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-06.
//

import Foundation
import ArgumentParser
import RayGun

struct Rename: ParsableCommand {
	static var configuration = CommandConfiguration(abstract: "Renames a key with another key.")
	
	func validate() throws {
		throw ArgumentParser.ValidationError("This command isn't yet implemented.")
	}
	
	func run() throws {
		
	}
}
