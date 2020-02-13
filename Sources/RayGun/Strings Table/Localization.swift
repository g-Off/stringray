//
//  Localization.swift
//  
//
//  Created by Geoffrey Foster on 2020-02-09.
//

import Foundation
import Files

public final class Localization {
	public private(set) var all: [LocalizedString]
	
	public var strings: [LocalizedString] { all.filter { !$0.isPlural } }
	public var pluralizations: [LocalizedString] { all.filter { $0.isPlural } }
	
	public var allKeys: Set<String> { Set(all.map { $0.key }) }
	
	/// The table name of this localization
	public let name: String
	/// The locale of this localization
	public let locale: String
	
	/// Initializes a new table with the given name for the given locale.
	/// - Parameters:
	///   - name: The name of the table.
	///   - locale: The locale.
	///   - strings: 
	public init(name: String, locale: String, strings: [LocalizedString] = []) {
		self.name = name
		self.locale = locale
		self.all = strings
	}
	
	public convenience init(name: String, folder: Folder) throws {
		var strings: [LocalizedString] = []
		let locale = folder.nameExcludingExtension
		if let file = try? folder.file(named: "\(name).strings") {
			let contents = try LocalizedString.parse(string: try file.readAsString())
			strings.append(contentsOf: contents)
		}
		if let file = try? folder.file(named: "\(name).stringsdict") {
			let contents = try LocalizedString.load(data: try file.read())
			strings.append(contentsOf: contents)
		}
		self.init(name: name, locale: locale, strings: strings)
	}
	
	/// Returns all strings with a matching key.
	public subscript(key: String) -> [LocalizedString] {
		all.filter { $0.key == key }
	}
	
	/// Returns all strings with a key that matches the given `Match`.
	public subscript(match: Match) -> [LocalizedString] {
		all.filter { match.matches(key: $0.key) }
	}
	
	public func add(_ string: LocalizedString) {
		all.append(string)
	}
	
	public func add(key: String, value: String, comment: String? = nil) {
		add(LocalizedString(key: key, value: .text(value), comment: comment, location: nil))
	}
	
	public func add(_ strings: [LocalizedString]) {
		self.all.append(contentsOf: strings)
	}
	
	public func remove(key: String) {
		all.removeAll {
			$0.key == key
		}
	}
	
	public func removeAll() {
		all.removeAll()
	}
	
	public func removeAll(where shouldBeRemoved: (LocalizedString) throws -> Bool) rethrows {
		try all.removeAll(where: shouldBeRemoved)
	}
	
	public func remove(_ localizedStrings: Set<LocalizedString>) {
		all.removeAll { localizedStrings.contains($0) }
	}
	
	public func replace(matches: [Match], replacements replacementStrings: [String]) {
		for (match, replacement) in zip(matches, replacementStrings) {
			for i in 0..<all.count {
				if let replacementKey = match.replacing(with: replacement, in: all[i].key) {
					all[i].key = replacementKey
				}
			}
		}
	}
	
	private func writeStrings(to file: File) throws {
		do {
			let handle = try FileHandle(forWritingTo: file.url)
			try handle.truncate(atOffset: 0)
			let stringsToWrite = strings
			for i in 0..<stringsToWrite.count {
				let localizedString = stringsToWrite[i]
				if let comment = localizedString.comment {
					handle.write("/* \(comment) */")
				}
				handle.write(#""\#(localizedString.key)" = "\#(localizedString.text)";"#)
				if (i + 1) < strings.count {
					handle.write("")
				}
			}
            handle.closeFile()
        } catch {
			throw WriteError(path: file.path, reason: .writeFailed(error))
        }
	}
	
	private func writeStringsDict(to folder: Folder) throws {
		let keysWithValues = pluralizations.map {
			($0.key, $0.pluralization!)
		}
		
		let pluralizations: [String: Pluralization] = .init(uniqueKeysWithValues: keysWithValues)
		
		let encoder = PropertyListEncoder()
		encoder.outputFormat = .xml
		let data = try encoder.encode(pluralizations)
		//try data.write(to: file.url, options: .atomicWrite)
		try folder.createFile(at: "\(name).stringsdict", contents: data)
	}
	
	public func write(to folder: Folder) throws {
		var folder = folder
		if folder.name != "\(locale).lproj" {
			folder = try folder.createSubfolderIfNeeded(at: "\(locale).lproj")
		}
		let file = try folder.createFileIfNeeded(at: "\(name).strings")
		try writeStrings(to: file)
		
		try writeStringsDict(to: folder)
	}
	
	public func sort() {
		all.sort { (lhs, rhs) -> Bool in
			lhs.key < rhs.key
		}
	}
}

private extension FileHandle {
	private static let newline: Data = "\n".data(using: .utf8)!
	func write(_ string: String) {
		guard let data = string.data(using: .utf8) else { return }
		write(data)
		write(Self.newline)
	}
}
