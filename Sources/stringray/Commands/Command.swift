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
	
	func cacheURL(for url: Foundation.URL) -> Foundation.URL? {
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
	
	func localizationCache(for url: Foundation.URL) -> LocalizationCache? {
		guard let localizationURL = cacheURL(for: url) else { return nil }
		do {
			let decoder = PropertyListDecoder()
			let localizationData = try Data(contentsOf: localizationURL)
			return try decoder.decode(LocalizationCache.self, from: localizationData)
		} catch {
			return nil
		}
	}
	
	func localization(for url: Foundation.URL) -> Localization? {
		guard let localizationCache = localizationCache(for: url) else { return nil }
		if LocalizationCache.GenerationIdentifier(url: url) == localizationCache.generationIdentifier {
			return localizationCache.localization
		}
		return nil
	}
	
	func save(localization: Localization, options: SaveOptions) throws {
		var localization = localization
		if options.contains(.sortedKeys) {
			localization.sort()
		}
		if options.contains(.writeFile) {
			for (languageId, languageEntries) in localization.entries {
				let lprojURL = localization.resourceDirectory.appendingPathComponent(languageId, isDirectory: true)
				try FileManager.default.createDirectory(at: lprojURL, withIntermediateDirectories: true, attributes: nil)
				let fileURL = lprojURL.appendingPathComponent(localization.baseURL.lastPathComponent)
				guard let outputStream = OutputStream(url: fileURL, append: false) else { continue }
				outputStream.open()
				var firstEntry = true
				for entry in languageEntries {
					if !firstEntry {
						outputStream.write(string: "\n")
					}
					firstEntry = false
					if let comment = entry.comment {
						outputStream.write(string: "/* \(comment) */\n")
					}
					outputStream.write(string: "\"\(entry.key)\" = \"\(entry.value)\";\n")
				}
				outputStream.close()
			}
		}
		
		if options.contains(.writeCache), let generationIdentifier = LocalizationCache.GenerationIdentifier(url: localization.baseURL), let cacheURL = cacheURL(for: localization.baseURL) {
			let localizationCache = LocalizationCache(generationIdentifier: generationIdentifier, localization: localization)
			let encoder = PropertyListEncoder()
			encoder.outputFormat = .binary
			let data = try encoder.encode(localizationCache)
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
