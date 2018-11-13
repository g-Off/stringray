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

struct SaveOptions : OptionSet {
	public private(set) var rawValue: UInt
	public init(rawValue: UInt) { self.rawValue = rawValue }
	
	public static let sortedKeys = SaveOptions(rawValue: 1 << 0)
	public static let writeFile = SaveOptions(rawValue: 1 << 1)
}

extension Command {
	
	func write(to url: Foundation.URL, table: StringsTable, options: SaveOptions) throws {
		var table = table
		if options.contains(.sortedKeys) {
			table.sort()
		}
		if options.contains(.writeFile) {
			for (languageId, languageEntries) in table.entries {
				let fileURL = try url.stringsURL(tableName: table.name, locale: languageId)
				guard let outputStream = OutputStream(url: fileURL, append: false) else { continue }
				outputStream.open()
				var firstEntry = true
				for entry in languageEntries {
					if !firstEntry {
						outputStream.write(string: "\n")
					}
					firstEntry = false
					if let comment = entry.comment {
						outputStream.write(string: "\(comment)\n")
					}
					outputStream.write(string: "\(entry.keyedValue)\n")
				}
				outputStream.close()
			}
			
			for (languageId, languageEntries) in table.dictEntries {
				let fileURL = try url.stringsDictURL(tableName: table.name, locale: languageId)
				let encoder = PropertyListEncoder()
				encoder.outputFormat = .xml
				let data = try encoder.encode(languageEntries)
				try data.write(to: fileURL, options: [.atomic])
			}
		}
	}
}

private extension OutputStream {
	func write(string: String) {
		let encodedDataArray = [UInt8](string.utf8)
		write(encodedDataArray, maxLength: encodedDataArray.count)
	}
}
