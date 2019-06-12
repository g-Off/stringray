//
//  CachedStringsTable.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-12-12.
//

import Foundation

struct CachedStringsTable: Codable {
	let stringsTable: StringsTable
	let cacheKeys: [String: Date]
	
	enum LocalizationType {
		case strings
		case stringsdict
	}
	
    init(stringsTable: StringsTable, cacheKeys: [String: Date]) {
        self.stringsTable = stringsTable
        self.cacheKeys = cacheKeys
    }
	
	func strings(for locale: Locale) -> OrderedSet<StringsTable.Entry>? {
		return stringsTable.entries[locale]
	}
	
	func stringsDict(for locale: Locale) -> [String: StringsTable.DictEntry]? {
		return stringsTable.dictEntries[locale]
	}
	
	func isCacheValid(for locale: Locale, type: LocalizationType, base: Foundation.URL) -> Bool {
		do {
			let fileURL: Foundation.URL
			switch type {
			case .strings:
				fileURL = try base.stringsURL(tableName: stringsTable.name, locale: locale)
			case .stringsdict:
				fileURL = try base.stringsDictURL(tableName: stringsTable.name, locale: locale)
			}
			let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
			guard let modificationDate = attributes[.modificationDate] as? Date else { return false }
			return modificationDate == cacheKeys[CachedStringsTable.cacheKey(for: locale, type: type)]
		} catch {
			return false
		}
	}
	
	static func cacheKey(for locale: Locale, type: LocalizationType) -> String {
		switch type {
		case .strings:
			return "\(locale.identifier).strings"
		case .stringsdict:
			return "\(locale.identifier).stringsdict"
		}
	}
}
