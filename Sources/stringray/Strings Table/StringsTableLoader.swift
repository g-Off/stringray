//
//  StringsTableLoader.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-20.
//

import Foundation

struct StringsTableLoader {
	private enum Error: String, Swift.Error, LocalizedError {
		case invalidURL
		
		var errorDescription: String? {
			switch self {
			case .invalidURL:
				return "Invalid string resource URL provided."
			}
		}
	}
	
	struct Options: OptionSet {
		public private(set) var rawValue: UInt
		public init(rawValue: UInt) { self.rawValue = rawValue }
		
		public static let lineNumbers = Options(rawValue: 1 << 0)
		public static let ignoreCached = Options(rawValue: 1 << 1)
	}
	
	var options: Options = []
	
	func load(url: URL) throws -> StringsTable {
		let resourceDirectory = url.resourceDirectory
		guard let name = url.tableName, let base = url.locale else {
			throw Error.invalidURL
		}
		return try self.load(url: resourceDirectory, name: name, base: base)
	}
	
	func load(url: URL, name: String, base: Locale) throws -> StringsTable {
		var entries: StringsTable.EntriesType = [:]
		var dictEntries: StringsTable.DictEntriesType = [:]
		
		var cached: CachedStringsTable?
		if !options.contains(.ignoreCached), let url = cacheURL(for: name), let data = try? Data(contentsOf: url) {
			let decoder = PropertyListDecoder()
			cached = try? decoder.decode(CachedStringsTable.self, from: data)
		}
		
		try url.lprojURLs.forEach {
			guard let locale = $0.locale else { return }
			
			let stringsTableURL = $0.appendingPathComponent(name).appendingPathExtension("strings")
			if let cached = cached, cached.isCacheValid(for: locale, type: .strings, base: url), let cachedStrings = cached.strings(for: locale) {
				entries[locale] = cachedStrings
			} else if let reachable = try? stringsTableURL.checkResourceIsReachable(), reachable == true {
				entries[locale] = try load(from: stringsTableURL, options: options)
			}
			
			let stringsDictTableURL = $0.appendingPathComponent(name).appendingPathExtension("stringsdict")
			if let cached = cached, cached.isCacheValid(for: locale, type: .stringsdict, base: url), let cachedStringsDict = cached.stringsDict(for: locale) {
				dictEntries[locale] = cachedStringsDict
			} else if let reachable = try? stringsDictTableURL.checkResourceIsReachable(), reachable == true {
				dictEntries[locale] = try load(from: stringsDictTableURL)
			}
		}
		
		return StringsTable(name: name, base: base, entries: entries, dictEntries: dictEntries)
	}
	
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
	
	func writeCache(table: StringsTable, baseURL: URL) throws {
		var cacheKeys: [String: Date] = [:]
		
		for (languageId, languageEntries) in table.entries where !languageEntries.isEmpty {
			let fileURL = try baseURL.stringsURL(tableName: table.name, locale: languageId)
			let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
			guard let modificationDate = attributes[.modificationDate] as? Date else { continue }
			cacheKeys[CachedStringsTable.cacheKey(for: languageId, type: .strings)] = modificationDate
		}
		
		for (languageId, languageEntries) in table.dictEntries where !languageEntries.isEmpty {
			let fileURL = try baseURL.stringsDictURL(tableName: table.name, locale: languageId)
			let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
			guard let modificationDate = attributes[.modificationDate] as? Date else { continue }
			cacheKeys[CachedStringsTable.cacheKey(for: languageId, type: .stringsdict)] = modificationDate
		}
		
		let cachedTable = CachedStringsTable(stringsTable: table, cacheKeys: cacheKeys)
		let encoder = PropertyListEncoder()
		encoder.outputFormat = .binary
		let cachedData = try encoder.encode(cachedTable)
		guard let url = cacheURL(for: table.name) else { return }
		try cachedData.write(to: url, options: [.atomic])
	}
	
	private func cacheURL(for tableName: String) -> Foundation.URL? {
		let bundleIdentifier = Bundle.main.bundleIdentifier ?? "net.g-Off.stringray"
		let filePath = "\(bundleIdentifier)/\(tableName).localization"
		guard let cacheURL = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: URL(fileURLWithPath: filePath), create: true)
			else {
				return nil
		}
		let fileURL = URL(fileURLWithPath: filePath, relativeTo: cacheURL)
		try! FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
		return URL(fileURLWithPath: filePath, relativeTo: cacheURL)
	}
	
	private func load(from url: URL, options: Options) throws -> OrderedSet<StringsTable.Entry> {
		func lineNumber(scanLocation: Int, newlineLocations: [Int]) -> Int {
			var lastIndex = 0
			for (index, newlineLocation) in newlineLocations.enumerated() {
				if newlineLocation > scanLocation {
					break
				}
				lastIndex = index
			}
			return lastIndex
		}
		
		let regex = try NSRegularExpression(pattern: "\"(?<key>.*)\"\\s*=\\s*\"(?<value>.*)\"", options: [])
		let baseString = try String(contentsOf: url)
		
		var newlineLocations: [Int] = []
		if options.contains(.lineNumbers) {
			baseString.enumerateSubstrings(in: baseString.startIndex..<baseString.endIndex, options: [.byLines, .substringNotRequired]) { (_, substringRange, _, stop) in
				newlineLocations.append(substringRange.lowerBound.encodedOffset)
			}
		}
		
		var entries: [StringsTable.Entry] = []
		let scanner = Scanner(string: baseString)
		while !scanner.isAtEnd {
			var entry = StringsTable.Entry()
			if options.contains(.lineNumbers) {
				entry.location = StringsTable.Entry.Location()
			}
			if scanner.scanString("/*", into: nil) {
				var scannedComment: NSString?
				if options.contains(.lineNumbers) {
					entry.location?.comment = lineNumber(scanLocation: scanner.scanLocation, newlineLocations: newlineLocations)
				}
				scanner.scanUpTo("*/\n", into: &scannedComment)
				scanner.scanString("*/\n", into: nil)
				if let scannedComment = scannedComment?.trimmingCharacters(in: CharacterSet.whitespaces) as String? {
					entry.comment = scannedComment
				}
			}
			scanner.scanCharacters(from: .whitespacesAndNewlines, into: nil)
			var scannedString: NSString?
			scanner.scanUpTo(";\n", into: &scannedString)
			scanner.scanString(";\n", into: nil)
			if options.contains(.lineNumbers) {
				entry.location?.line = lineNumber(scanLocation: scanner.scanLocation, newlineLocations: newlineLocations)
			}
			
			if let scannedString = scannedString {
				regex.enumerateMatches(in: scannedString as String, options: [], range: NSRange(location: 0, length: scannedString.length)) { (result, flags, done) in
					guard let result = result else { return }
					entry.key = scannedString.substring(with: result.range(withName: "key"))
					entry.value = scannedString.substring(with: result.range(withName: "value"))
					entries.append(entry)
				}
			}
		}
		return OrderedSet(entries)
	}
	
	private func load(from url: URL) throws -> [String: StringsTable.DictEntry] {
		let data = try Data(contentsOf: url)
		let decoder = PropertyListDecoder()
		return try decoder.decode([String: StringsTable.DictEntry].self, from: data)
	}
}

private extension OutputStream {
	func write(string: String) {
		let encodedDataArray = [UInt8](string.utf8)
		write(encodedDataArray, maxLength: encodedDataArray.count)
	}
}
