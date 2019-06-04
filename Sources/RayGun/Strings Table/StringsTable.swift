//
//  StringsTable.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-02.
//  Copyright © 2018 g-Off.net. All rights reserved.
//

import Foundation

public struct StringsTable: Codable {
	public typealias EntriesType = [Locale: OrderedSet<Entry>]
	public typealias DictEntriesType = [Locale: [String: DictEntry]]
	
	private enum CodingKeys: String, CodingKey {
		case name
		case base
		case entries
		case dictEntries
	}
	
	public let name: String
	public let base: Locale
	public private(set) var entries: EntriesType = [:]
	public private(set) var dictEntries: DictEntriesType = [:]
	
	private var allLanguageKeys: Set<Locale> {
		var keys: Set<Locale> = []
		keys.formUnion(entries.keys)
		keys.formUnion(dictEntries.keys)
		return keys
	}
	
	public var baseEntries: OrderedSet<Entry> {
		return entries[base] ?? []
	}
	
	public var localizedEntries: EntriesType {
		var localizedEntries = entries
		localizedEntries.removeValue(forKey: base)
		return localizedEntries
	}
	
	public var baseDictEntries: [String: DictEntry] {
		return dictEntries[base] ?? [:]
	}
	
	public init(name: String, base: Locale, entries: EntriesType = [:], dictEntries: DictEntriesType = [:]) {
		self.name = name
		self.base = base
		self.entries = entries
		self.dictEntries = dictEntries
	}
	
	private func entries(for locale: Locale, matching: [Match]) -> OrderedSet<Entry>? {
		guard let matchingEntries = entries[locale]?.filter({ (entry) -> Bool in
			return matching.matches(key: entry.key)
		}) else { return nil }
		return OrderedSet(matchingEntries)
	}
	
	public func withKeys(matching: [Match]) -> StringsTable {
		var filteredEntries: EntriesType = [:]
		var filteredDictEntries: DictEntriesType = [:]
		
		for locale in allLanguageKeys {
			if let matchingEntries = entries(for: locale, matching: matching) {
				filteredEntries[locale] = matchingEntries
			}
			
			if let matchingDictEntries = dictEntries[locale]?.filter({ (key, value) -> Bool in
				return matching.matches(key: key)
			}) {
				filteredDictEntries[locale] = matchingDictEntries
			}
		}
		
		var table = self
		table.entries = filteredEntries
		table.dictEntries = filteredDictEntries
		return table
	}
	
	public mutating func addEntries(from table: StringsTable) {
		for (languageId, languageEntries) in table.entries {
			entries[languageId, default: []].formUnion(languageEntries)
		}
		
		for (languageId, languageEntries) in table.dictEntries {
			dictEntries[languageId, default: [:]].merge(languageEntries, uniquingKeysWith: { (lhs, rhs) in
				return rhs
			})
		}
	}
	
	public mutating func removeEntries(from table: StringsTable) {
		for (languageId, languageEntries) in table.entries {
			entries[languageId]?.subtract(languageEntries)
		}
		
		for (languageId, languageEntries) in table.dictEntries {
			languageEntries.keys.forEach {
				dictEntries[languageId]?.removeValue(forKey: $0)
			}
		}
	}
	
	public mutating func sort() {
		for (languageId, languageEntries) in entries {
			var sortedLanguageEntries = languageEntries
			sortedLanguageEntries.sort { (lhs, rhs) -> Bool in
				return lhs.key < rhs.key
			}
			entries.updateValue(sortedLanguageEntries, forKey: languageId)
		}
	}
	
	public mutating func remove(keys: Set<String>) {
		for (locale, entry) in entries {
			let filtered = entry.filter {
				return !keys.contains($0.key)
			}
			entries[locale] = OrderedSet(filtered)
		}
	}
	
	private mutating func replace(entry: Entry, with otherEntry: Entry, locale: Locale) {
		guard let index = entries[locale]?.firstIndex(of: entry) else { return }
		entries[locale]?[index] = otherEntry
	}
	
	private mutating func replace(key: String, with otherKey: String, locale: Locale) {
		guard let entry = dictEntries[locale]?[key] else { return }
		dictEntries[locale]?[otherKey] = entry
	}
	
	public mutating func replace(matches: [Match], replacements replacementStrings: [String]) {
		for (match, replacement) in zip(matches, replacementStrings) {
			for localizedEntries in entriesMatching(match) {
				localizedEntries.value.forEach {
					var entry = $0
					if let replacementKey = match.replacing(with: replacement, in: entry.key) {
						entry.key = replacementKey
					}
					replace(entry: $0, with: entry, locale: localizedEntries.key)
				}
			}
			
			for localizedEntries in dictEntriesMatching(match) {
				localizedEntries.value.forEach {
					if let replacementKey = match.replacing(with: replacement, in: $0.key) {
						replace(key: $0.key, with: replacementKey, locale: localizedEntries.key)
					}
				}
			}
		}
	}
	
	// MARK: -
	
	private func entriesMatching(_ match: Match) -> EntriesType {
		var matches: EntriesType = [:]
		for localizedEntry in entries {
			matches[localizedEntry.key] = OrderedSet<Entry>(localizedEntry.value.filter({ match.matches(key: $0.key) }))
		}
		return matches
	}
	
	private func dictEntriesMatching(_ match: Match) -> DictEntriesType {
		var matches: DictEntriesType = [:]
		for localizedEntry in dictEntries {
			matches[localizedEntry.key] = localizedEntry.value.filter { match.matches(key: $0.key) }
		}
		return matches
	}
}
