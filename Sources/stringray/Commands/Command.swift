//
//  Command.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-04.
//

import Foundation
import Utility

protocol Command {
	var command: String { get }
	var overview: String { get }
	
	init(parser: ArgumentParser)
	func run(with arguments: ArgumentParser.Result) throws
}

extension Command {
	func write(to url: Foundation.URL, table: StringsTable) throws {
		for (languageId, languageEntries) in table.entries where !languageEntries.isEmpty {
			let fileURL = try url.stringsURL(tableName: table.name, locale: languageId)
			guard let outputStream = OutputStream(url: fileURL, append: false) else { continue }
			outputStream.open()
			var firstEntry = true
			for entry in languageEntries {
				if !firstEntry {
					outputStream.write(string: "\n")
				}
				firstEntry = false
				outputStream.write(string: "\(entry)\n")
			}
			outputStream.close()
		}
		
		for (languageId, languageEntries) in table.dictEntries where !languageEntries.isEmpty {
			let fileURL = try url.stringsDictURL(tableName: table.name, locale: languageId)
			let encoder = PropertyListEncoder()
			encoder.outputFormat = .xml
			let data = try encoder.encode(languageEntries)
			try data.write(to: fileURL, options: [.atomic])
		}
	}
}

private extension OutputStream {
	func write(string: String) {
		let encodedDataArray = [UInt8](string.utf8)
		write(encodedDataArray, maxLength: encodedDataArray.count)
	}
}
