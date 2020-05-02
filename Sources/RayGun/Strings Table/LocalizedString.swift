//
//  LocalizedString.swift
//  
//
//  Created by Geoffrey Foster on 2020-02-09.
//

import Foundation

public struct LocalizedString {
	public enum Value: Equatable, Hashable {
		case text(String)
		case plural(Pluralization)
	}
	
	public var key: String
	public var value: Value
	
	public var comment: String?
	public var location: Location?
}

extension LocalizedString: Equatable {
	public static func == (lhs: LocalizedString, rhs: LocalizedString) -> Bool {
		return lhs.key == rhs.key && lhs.value == rhs.value
	}
}

extension LocalizedString: Hashable {}

public extension LocalizedString {
	var text: String {
		guard case let .text(string) = value else { return "" }
		return string
	}
	
	var pluralization: Pluralization? {
		guard case let .plural(pluralization) = value else { return nil }
		return pluralization
	}
}

extension LocalizedString {
	var isPlural: Bool {
		if case .plural = value {
			return true
		}
		return false
	}
}

extension LocalizedString {
	static func parse(string: String) throws -> [LocalizedString] {
		var strings: [LocalizedString] = []
		let regex = try NSRegularExpression(pattern: "\"(?<key>.*)\"\\s*=\\s*\"(?<value>.*)\"", options: [])
		
		let scanner = Scanner(string: string)
		while !scanner.isAtEnd {
			var comment: String?
			var key: String?
			var value: String?
			
			if let _ = scanner.scanString("/*") {
				comment = scanner.scanUpToString("*/\n")?.trimmingCharacters(in: CharacterSet.whitespaces)
				_ = scanner.scanString("*/\n")
			}
			_ = scanner.scanCharacters(from: .whitespacesAndNewlines)
			if let scannedString = scanner.scanUpToString(";\n") {
				let range = NSRange(scannedString.startIndex..<scannedString.endIndex, in: scannedString)
				regex.enumerateMatches(in: scannedString, options: [], range: range) { (result, flags, done) in
					guard
						let result = result,
						let keyRange = Range<String.Index>(result.range(withName: "key"), in: scannedString),
						let valueRange = Range<String.Index>(result.range(withName: "value"), in: scannedString) else {
							return
					}
					key = String(scannedString[keyRange])
					value = String(scannedString[valueRange])
				}
				_ = scanner.scanString(";\n")
			}
			
			if let key = key, let value = value {
				// TODO: capture location
				strings.append(LocalizedString(key: key, value: .text(value), comment: comment, location: nil))
			}
			
			_ = scanner.scanCharacters(from: .whitespacesAndNewlines)
		}
		return strings
	}
	
	static func load(data: Data) throws -> [LocalizedString] {
		var strings: [LocalizedString] = []
		let decoder = PropertyListDecoder()
		let pluralizations = try decoder.decode([String: Pluralization].self, from: data)
		pluralizations.forEach { (key, pluralization) in
			strings.append(LocalizedString(key: key, value: .plural(pluralization), comment: nil, location: nil))
		}
		return strings
	}
}
