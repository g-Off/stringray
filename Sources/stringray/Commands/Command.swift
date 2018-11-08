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
	public static let writeCache = SaveOptions(rawValue: 1 << 2)
}

extension Command {
	
	private func cacheURL(for url: Foundation.URL) -> Foundation.URL? {
		let bundleIdentifier = Bundle.main.bundleIdentifier ?? "net.g-Off.stringray"
		let filePath = "\(bundleIdentifier)/\(url.deletingPathExtension().lastPathComponent).localization"
		guard let cacheURL = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: URL(fileURLWithPath: filePath), create: true)
			else {
				return nil
		}
		let fileURL = URL(fileURLWithPath: filePath, relativeTo: cacheURL)
		try! FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
		return URL(fileURLWithPath: filePath, relativeTo: cacheURL)
	}
	
	private func tableCache(for url: Foundation.URL) -> TableCache? {
		guard let tableURL = cacheURL(for: url) else { return nil }
		do {
			let decoder = PropertyListDecoder()
			let tableData = try Data(contentsOf: tableURL)
			return try decoder.decode(TableCache.self, from: tableData)
		} catch {
			return nil
		}
	}
	
	func loadTable(for url: Foundation.URL) throws -> StringsTable {
		if let tableCache = tableCache(for: url), TableCache.GenerationIdentifier(url: url) == tableCache.generationIdentifier {
			return tableCache.table
		}
		return try StringsTable(url: url)
	}
	
	func save(table: StringsTable, options: SaveOptions) throws {
		var table = table
		if options.contains(.sortedKeys) {
			table.sort()
		}
		if options.contains(.writeFile) {
			for (languageId, languageEntries) in table.entries {
				let lprojURL = table.resourceDirectory.appendingPathComponent(languageId, isDirectory: true)
				try FileManager.default.createDirectory(at: lprojURL, withIntermediateDirectories: true, attributes: nil)
				let fileURL = lprojURL.appendingPathComponent(table.baseURL.lastPathComponent)
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
		}
		
		if options.contains(.writeCache), let generationIdentifier = TableCache.GenerationIdentifier(url: table.baseURL), let cacheURL = cacheURL(for: table.baseURL) {
			let tableCache = TableCache(generationIdentifier: generationIdentifier, table: table)
			let encoder = PropertyListEncoder()
			encoder.outputFormat = .binary
			let data = try encoder.encode(tableCache)
			try data.write(to: cacheURL)
		}
	}
}

private extension OutputStream {
	func write(string: String) {
		let encodedDataArray = [UInt8](string.utf8)
		write(encodedDataArray, maxLength: encodedDataArray.count)
	}
}
