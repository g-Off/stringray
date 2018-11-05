//
//  LocalizationCache.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-02.
//

import Foundation

struct LocalizationCache: Codable {
	struct GenerationIdentifier: Codable, Equatable {
		private let identifier: String
		
		init?(url: URL) {
			guard let resourceValues = try? url.resourceValues(forKeys: [.generationIdentifierKey]),
				let generationIdentifier = resourceValues.generationIdentifier else {
					return nil
			}
			let data = NSKeyedArchiver.archivedData(withRootObject: generationIdentifier)
			self.identifier = data.base64EncodedString()
		}
		
		init(from decoder: Decoder) throws {
			let container = try decoder.singleValueContainer()
			self.identifier = try container.decode(String.self)
		}
		
		func encode(to encoder: Encoder) throws {
			var container = encoder.singleValueContainer()
			try container.encode(identifier)
		}
	}
	let generationIdentifier: GenerationIdentifier
	let localization: Localization
	
	init(generationIdentifier: GenerationIdentifier, localization: Localization) {
		self.generationIdentifier = generationIdentifier
		self.localization = localization
	}
}
