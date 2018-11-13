//
//  URL+Extensions.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-10.
//

import Foundation

extension URL {
	var tableName: String? {
		return tableComponents?.name
	}
	
	var locale: String? {
		return tableComponents?.locale
	}
	
	var resourceDirectory: URL {
		var dir = self
		if dir.pathExtension == "strings" || dir.pathExtension == "stringsdict" {
			dir.deleteLastPathComponent()
		}
		if dir.pathExtension == "lproj" {
			dir.deleteLastPathComponent()
		}
		return dir
	}
	
	var tableComponents: (name: String, locale: String)? {
		guard pathExtension == "strings" || pathExtension == "stringsdict" else { return nil }
		let name = deletingPathExtension().lastPathComponent
		let lproj = deletingLastPathComponent()
		guard lproj.pathExtension == "lproj" else { return nil }
		let base = lproj.deletingPathExtension().lastPathComponent
		return (name, base)
	}
	
	var lprojURLs: [URL] {
		let directories = try? FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: []).filter { (url) -> Bool in
			return url.pathExtension == "lproj"
		}
		return directories ?? []
	}
	
	func stringsFiles(tableName: String) -> [URL] {
		return files(tableName: tableName, ext: "strings")
	}
	
	func stringsDictFiles(tableName: String) -> [URL] {
		return files(tableName: tableName, ext: "stringsdict")
	}
	
	private func files(tableName: String, ext: String) -> [URL] {
		return lprojURLs.compactMap { (lprojURL) in
			let url = lprojURL.appendingPathComponent(tableName).appendingPathExtension(ext)
			guard let reachable = try? url.checkResourceIsReachable(), reachable == true else { return nil }
			return url
		}
	}
	
	func stringsURL(tableName: String, locale: String) throws -> URL {
		return try fileURL(tableName: tableName, locale: locale, ext: "strings", create: true)
	}
	
	func stringsDictURL(tableName: String, locale: String) throws -> URL {
		return try fileURL(tableName: tableName, locale: locale, ext: "stringsdict", create: true)
	}
	
	private func fileURL(tableName: String, locale: String, ext: String, create: Bool) throws -> URL {
		let lprojURL = appendingPathComponent("\(locale).lproj", isDirectory: true)
		if create {
			try FileManager.default.createDirectory(at: lprojURL, withIntermediateDirectories: true, attributes: nil)
		}
		let fileURL = lprojURL.appendingPathComponent(tableName).appendingPathExtension(ext)
		return fileURL
	}
}
