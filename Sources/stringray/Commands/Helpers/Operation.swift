//
//  Operation.swift
//  
//
//  Created by Geoffrey Foster on 2020-03-05.
//

import Foundation
import RayGun
import Files

enum Operation {
	case copy
	case move
	case delete
	
	func perform(inputs: Input, outputs: Output, locale: String, matching: [Match]) throws {
		let lproj = "\(locale).lproj"
		let sourceLocalization = try inputs.loadLocalization(locale)
		let outputFolder = try outputs.output.createSubfolderIfNeeded(at: lproj)
		let destinationLocalization = try Localization(name: outputs.destination, folder: outputFolder)
		
		let copiedStrings: [LocalizedString]
		if matching.isEmpty {
			copiedStrings = sourceLocalization.all
		} else {
			copiedStrings = matching.flatMap { sourceLocalization[$0] }
		}
		
		destinationLocalization.add(copiedStrings)
		try destinationLocalization.write(to: outputFolder)
		
		if self == .move || self == .delete {
			sourceLocalization.remove(Set<LocalizedString>(copiedStrings))
			try sourceLocalization.write(to: inputs.folder(for: locale))
		}
	}
}
