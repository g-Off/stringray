//
//  Table.swift
//  
//
//  Created by Geoffrey Foster on 2020-02-12.
//

import Foundation
import Files

public final class Table {
	public let name: String
	public let base: String
	let path: Folder?
	
	public private(set) var localizations: [String: Localization] = [:]
	
	public convenience init(name: String, base: String) {
		try! self.init(name: name, base: base, path: nil)
	}
	
	public convenience init(name: String, base: String, path: String, ignoring: Set<String> = []) throws {
		try self.init(name: name, base: base, path: try Folder(path: path), ignoring: ignoring)
	}
	
	public convenience init?(base: String) throws {
		let file = try File(path: base)
		let name = file.nameExcludingExtension
		guard let base = file.parent?.nameExcludingExtension else { return nil }
		try self.init(name: name, base: base, path: file.parent?.parent)
	}
	
	public init(name: String, base: String, path: Folder?, ignoring: Set<String> = []) throws {
		self.name = name
		self.base = base
		self.path = path
		if path != nil {
			try load(ignoring: ignoring)
		}
	}
	
	public var baseLocalization: Localization {
		return localizations[base, default: Localization(name: name, locale: base)]
	}
	
	public func add(localization: Localization) {
		if let existingLocalization = localizations[localization.locale] {
			existingLocalization.add(localization.strings)
		} else {
			localizations[localization.locale] = localization
		}
	}
	
	public subscript(match: Match) -> [String: Localization] {
		var matchingLocalizations: [String: Localization] = [:]
		localizations.forEach { (locale, localization) in
			let matchingStrings = localization[match]
			matchingLocalizations[locale] = Localization(name: name, locale: locale, strings: matchingStrings)
		}
		return matchingLocalizations
	}
	
	public func save() throws {
		guard let path = path else { return } // TODO: throw an error instead
		try localizations.forEach {
			try $0.value.write(to: path)
		}
	}
	
	func load(ignoring: Set<String>) throws {
		guard let path = path else { return }
		try path.subfolders.filter { $0.extension == "lproj" }.filter { !ignoring.contains($0.nameExcludingExtension) }.forEach {
			let localization = try Localization(name: name, folder: $0)
			add(localization: localization)
		}
	}
}
