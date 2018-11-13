//
//  StringsTable.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-02.
//  Copyright © 2018 g-Off.net. All rights reserved.
//

import Foundation

struct StringsTable: Codable {
	private static func lprojURLs(from url: URL, tableName: String) throws -> [URL] {
		let directories = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: []).filter { (url) -> Bool in
			return url.pathExtension == "lproj"
		}
		return directories
	}
	
	private static func loadEntries(from url: URL, tableName: String) throws -> EntriesType {
		var languageEntries: EntriesType = [:]
		try lprojURLs(from: url, tableName: tableName).forEach {
			let key = $0.deletingPathExtension().lastPathComponent
			let stringsTableURL = $0.appendingPathComponent(tableName).appendingPathExtension("strings")
			if let reachable = try? stringsTableURL.checkResourceIsReachable(), reachable == true {
				languageEntries[key] = try Entry.load(from: stringsTableURL)
			}
		}
		return languageEntries
	}
	
	private static func loadDictEntries(from url: URL, tableName: String) throws -> DictEntriesType {
		var languageEntries: DictEntriesType = [:]
		try lprojURLs(from: url, tableName: tableName).forEach {
			let key = $0.deletingPathExtension().lastPathComponent
			let stringsDictTableURL = $0.appendingPathComponent(tableName).appendingPathExtension("stringsdict")
			if let reachable = try? stringsDictTableURL.checkResourceIsReachable(), reachable == true {
				languageEntries[key] = try DictEntry.load(from: stringsDictTableURL)
			}
		}
		return languageEntries
	}
	
	typealias EntriesType = [String: OrderedSet<Entry>]
	typealias DictEntriesType = [String: [String: DictEntry]]
	private enum CodingKeys: String, CodingKey {
		case name
		case base
		case entries
		case dictEntries
	}
	
	let name: String
	let base: String
	private(set) var entries: EntriesType = [:]
	private(set) var dictEntries: DictEntriesType = [:]
	
	private var allLanguageKeys: Set<String> {
		var keys: Set<String> = []
		keys.formUnion(entries.keys)
		keys.formUnion(dictEntries.keys)
		return keys
	}
	
	var baseEntries: OrderedSet<Entry> {
		return entries[base] ?? []
	}
	
	var baseDictEntries: [String: DictEntry] {
		return dictEntries[base] ?? [:]
	}
	
	private enum Error: String, Swift.Error {
		case invalidURL
	}
	
	/// Initializes a `StringsTable` from an existing strings table on disk.
	///
	/// - Parameter url: File URL to the base localizations table. Example: `en.lproj/Shopify.strings`
	/// - Throws:
	init(url: URL) throws {
		let resourceDirectory = url.resourceDirectory
		guard let (name, base) = url.tableComponents else {
			throw Error.invalidURL
		}
		try self.init(url: resourceDirectory, name: name, base: base)
	}
	
	init(url: URL, name: String, base: String) throws {
		self.name = name
		self.base = base
		self.entries = try StringsTable.loadEntries(from: url, tableName: name)
		self.dictEntries = try StringsTable.loadDictEntries(from: url, tableName: name)
	}
	
	init(name: String, base: String, entries: EntriesType, dictEntries: DictEntriesType) {
		self.name = name
		self.base = base
		self.entries = entries
		self.dictEntries = dictEntries
	}
	
	private func entries(for languageKey: String, matching: [Match]) -> OrderedSet<Entry>? {
		guard let matchingEntries = entries[languageKey]?.filter({ (entry) -> Bool in
			return matching.matches(key: entry.keyedValue.key)
		}) else { return nil }
		return OrderedSet(matchingEntries)
	}
	
	func withKeys(matching: [Match]) -> StringsTable {
		var filteredEntries: EntriesType = [:]
		var filteredDictEntries: DictEntriesType = [:]
		
		for languageKey in allLanguageKeys {
			if let matchingEntries = entries(for: languageKey, matching: matching) {
				filteredEntries[languageKey] = matchingEntries
			}
			
			if let matchingDictEntries = dictEntries[languageKey]?.filter({ (key, value) -> Bool in
				return matching.matches(key: key)
			}) {
				filteredDictEntries[languageKey] = matchingDictEntries
			}
		}
		
		var table = self
		table.entries = filteredEntries
		table.dictEntries = filteredDictEntries
		return table
	}
	
	mutating func addEntries(from table: StringsTable) {
		for (languageId, languageEntries) in table.entries {
			entries[languageId, default: []].formUnion(languageEntries)
		}
		
		for (languageId, languageEntries) in table.dictEntries {
			dictEntries[languageId, default: [:]].merge(languageEntries, uniquingKeysWith: { (lhs, rhs) in
				return rhs
			})
		}
	}
	
	mutating func removeEntries(from table: StringsTable) {
		for (languageId, languageEntries) in table.entries {
			entries[languageId]?.subtract(languageEntries)
		}
		
		for (languageId, languageEntries) in table.dictEntries {
			languageEntries.keys.forEach {
				dictEntries[languageId]?.removeValue(forKey: $0)
			}
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
