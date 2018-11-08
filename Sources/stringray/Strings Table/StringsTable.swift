//
//  StringsTable.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-02.
//  Copyright © 2018 g-Off.net. All rights reserved.
//

import Foundation

struct StringsTable: Codable {
	struct Entry: Codable, Hashable {
		struct Comment: Codable, Hashable, CustomStringConvertible {
			let line: Int
			let value: String
			
			var description: String {
				return "/* \(value) */"
			}
		}
		struct KeyedValue: Codable, Hashable, CustomStringConvertible {
			let line: Int
			let key: String
			let value: String
			
			var description: String {
				return "\"\(key)\" = \"\(value)\";"
			}
		}

		let comment: Comment?
		let keyedValue: KeyedValue
		
		public static func ==(lhs: Entry, rhs: Entry) -> Bool {
			return lhs.keyedValue.key == rhs.keyedValue.key
		}
		
		public func hash(into hasher: inout Hasher) {
			hasher.combine(keyedValue.key)
		}
	}
	
	private enum CodingKeys: String, CodingKey {
		case baseURL
		case entries
	}
	
	let baseURL: URL
	var entries: [String: OrderedSet<Entry>] = [:] {
		didSet {
			if oldValue != entries {
				mutated = true
			}
		}
	}
	
	var baseLocale: String {
		return baseURL.deletingLastPathComponent().lastPathComponent
	}
	
	var baseEntries: OrderedSet<Entry> {
		return entries[baseLocale] ?? []
	}
	
	var mutated: Bool = false
	
	var resourceDirectory: URL {
		return baseURL.deletingLastPathComponent().deletingLastPathComponent()
	}
	
	init(url: URL) throws {
		self.baseURL = url
		self.entries = try StringsTable.loadAllEntries(from: resourceDirectory, fileName: url.lastPathComponent)
	}
	
	private init(baseURL: URL, entries: [String: OrderedSet<Entry>]) {
		self.baseURL = baseURL
		self.entries = entries
	}
	
	private static func loadEntries(from url: URL) throws -> OrderedSet<Entry> {
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
		baseString.enumerateSubstrings(in: baseString.startIndex..<baseString.endIndex, options: [.byLines, .substringNotRequired]) { (_, substringRange, _, stop) in
			newlineLocations.append(substringRange.lowerBound.encodedOffset)
		}
		
		var entries: [Entry] = []
		let scanner = Scanner(string: baseString)
		while !scanner.isAtEnd {
			var comment: Entry.Comment?
			if scanner.scanString("/*", into: nil) {
				var scannedComment: NSString?
				let location = lineNumber(scanLocation: scanner.scanLocation, newlineLocations: newlineLocations)
				scanner.scanUpTo("*/\n", into: &scannedComment)
				scanner.scanString("*/\n", into: nil)
				if let scannedComment = scannedComment?.trimmingCharacters(in: CharacterSet.whitespaces) as String? {
					comment = Entry.Comment(line: location, value: scannedComment)
				}
			}
			scanner.scanCharacters(from: .whitespacesAndNewlines, into: nil)
			var scannedString: NSString?
			scanner.scanUpTo(";\n", into: &scannedString)
			scanner.scanString(";\n", into: nil)
			let keyValueLocation = lineNumber(scanLocation: scanner.scanLocation, newlineLocations: newlineLocations)
			
			if let scannedString = scannedString {
				regex.enumerateMatches(in: scannedString as String, options: [], range: NSRange(location: 0, length: scannedString.length)) { (result, flags, done) in
					guard let result = result else { return }
					let key = scannedString.substring(with: result.range(withName: "key"))
					let value = scannedString.substring(with: result.range(withName: "value"))
					let keyedValue = Entry.KeyedValue(line: keyValueLocation, key: key, value: value)
					let entry = Entry(comment: comment, keyedValue: keyedValue)
					entries.append(entry)
				}
			}
		}
		return OrderedSet(entries)
	}
	
	private static func loadAllEntries(from url: URL, fileName: String) throws -> [String: OrderedSet<Entry>] {
		let languageDirectories = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: []).filter({ (url) -> Bool in
			return url.pathExtension == "lproj"
		})
		var languageEntries: [String: OrderedSet<Entry>] = [:]
		try languageDirectories.forEach {
			let key = $0.lastPathComponent
			let localizedEntriesURL = $0.appendingPathComponent(fileName)
			if let reachable = try? localizedEntriesURL.checkResourceIsReachable(), reachable == true {
				languageEntries[key] = try loadEntries(from: localizedEntriesURL)
			}
		}
		return languageEntries
	}
	
	func withKeys(matching: [Match]) -> StringsTable {
		var filteredEntries: [String: OrderedSet<Entry>] = [:]
		for (languageId, languageEntries) in entries {
			let matchingEntries = languageEntries.filter { entry in
				return matching.contains(where: { (matcher) -> Bool in
					switch matcher {
					case .prefix(let prefix):
						return entry.keyedValue.key.hasPrefix(prefix)
					case .regex(_): // TODO: support this eventually
						return false
					}
				})
			}
			filteredEntries[languageId] = OrderedSet(matchingEntries)
		}
		return StringsTable(baseURL: baseURL, entries: filteredEntries)
	}
	
	mutating func addEntries(from table: StringsTable) {
		for (languageId, languageEntries) in table.entries {
			entries[languageId, default: []].formUnion(languageEntries)
		}
	}
	
	mutating func removeEntries(from table: StringsTable) {
		for (languageId, languageEntries) in table.entries {
			entries[languageId]?.subtract(languageEntries)
		}
	}
	
	mutating func sort() {
		for (languageId, languageEntries) in entries {
			var sortedLanguageEntries = languageEntries
			sortedLanguageEntries.sort { (lhs, rhs) -> Bool in
				return lhs.keyedValue.key < rhs.keyedValue.key
			}
			entries.updateValue(sortedLanguageEntries, forKey: languageId)
			
		}
	}
}
