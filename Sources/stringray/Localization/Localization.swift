//
//  Localization.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-02.
//  Copyright © 2018 g-Off.net. All rights reserved.
//

import Foundation

struct Localization: Codable {
	struct Entry: Codable, Hashable {
		let comment: String?
		let key: String
		let value: String
		
		public static func ==(lhs: Entry, rhs: Entry) -> Bool {
			return lhs.key == rhs.key
		}
		
		public func hash(into hasher: inout Hasher) {
			hasher.combine(key)
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
	var mutated: Bool = false
	
	var resourceDirectory: URL {
		return baseURL.deletingLastPathComponent().deletingLastPathComponent()
	}
	
	init(url: URL) throws {
		self.baseURL = url
		self.entries = try Localization.loadAllEntries(from: resourceDirectory, fileName: url.lastPathComponent)
	}
	
	private init(baseURL: URL, entries: [String: OrderedSet<Entry>]) {
		self.baseURL = baseURL
		self.entries = entries
	}
	
	private static func loadEntries(from url: URL) throws -> OrderedSet<Entry> {
		let regex = try NSRegularExpression(pattern: "\"(?<key>.*)\"\\s*=\\s*\"(?<value>.*)\"", options: [])
		var entries: [Entry] = []
		let baseString = try String(contentsOf: url)
		let scanner = Scanner(string: baseString)
		while !scanner.isAtEnd {
			var scannedComment: NSString?
			if scanner.scanString("/*", into: nil) {
				scanner.scanUpTo("*/\n", into: &scannedComment)
				scanner.scanString("*/\n", into: nil)
			}
			scanner.scanCharacters(from: .whitespacesAndNewlines, into: nil)
			var scannedString: NSString?
			scanner.scanUpTo(";\n", into: &scannedString)
			scanner.scanString(";\n", into: nil)
			
			if let scannedString = scannedString {
				regex.enumerateMatches(in: scannedString as String, options: [], range: NSRange(location: 0, length: scannedString.length)) { (result, flags, done) in
					guard let result = result else { return }
					let key = scannedString.substring(with: result.range(withName: "key"))
					let value = scannedString.substring(with: result.range(withName: "value"))
					let entry = Entry(comment: scannedComment?.trimmingCharacters(in: CharacterSet.whitespaces) as String?, key: key, value: value)
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
	
	func withKeys(matching: [Match]) -> Localization {
		var filteredEntries: [String: OrderedSet<Entry>] = [:]
		for (languageId, languageEntries) in entries {
			let matchingEntries = languageEntries.filter { entry in
				return matching.contains(where: { (matcher) -> Bool in
					switch matcher {
					case .prefix(let prefix):
						return entry.key.hasPrefix(prefix)
					case .regex(_): // TODO: support this eventually
						return false
					}
				})
			}
			filteredEntries[languageId] = OrderedSet(matchingEntries)
		}
		return Localization(baseURL: baseURL, entries: filteredEntries)
	}
	
	mutating func addEntries(from localization: Localization) {
		for (languageId, languageEntries) in localization.entries {
			entries[languageId, default: []].formUnion(languageEntries)
		}
	}
	
	mutating func removeEntries(from localization: Localization) {
		for (languageId, languageEntries) in localization.entries {
			entries[languageId]?.subtract(languageEntries)
		}
	}
	
	mutating func sort() {
		for (languageId, languageEntries) in entries {
			var sortedLanguageEntries = languageEntries
			sortedLanguageEntries.sort { (lhs, rhs) -> Bool in
				return lhs.key < rhs.key
			}
			entries.updateValue(sortedLanguageEntries, forKey: languageId)
			
		}
	}
}
