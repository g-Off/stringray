//
//  PlaceholderType.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-13.
//

import Foundation

public enum PlaceholderType: String, Codable {
	case object = "String"
	case float = "Float"
	case int = "Int"
	case char = "CChar"
	case cString = "UnsafePointer<CChar>"
	case pointer = "UnsafeRawPointer"
	
	static let unknown = pointer
	
	init?(_ string: String) {
		guard let char = string.lowercased().first else {
			return nil
		}
		switch char {
		case "@":
			self = .object
		case "a", "e", "f", "g":
			self = .float
		case "d", "i", "o", "u", "x":
			self = .int
		case "c":
			self = .char
		case "s":
			self = .cString
		case "p":
			self = .pointer
		default:
			return nil
		}
	}
	
	private static let formatTypesRegEx: NSRegularExpression = {
		// %d/%i/%o/%u/%x with their optional length modifiers like in "%lld"
		let patternInt = "(?:h|hh|l|ll|q|z|t|j)?([dioux])"
		// valid flags for float
		let patternFloat = "[aefg]"
		// like in "%3$" to make positional specifiers
		let position = "((?<position>[1-9]\\d*)\\$)?"
		// precision like in "%1.2f"
		let precision = "[-+# 0]?\\d?(?:\\.\\d)?"
		
		let pattern = "(?:^|(?<!%)(?:%%)*)%\(position)\(precision)(?<type>@|\(patternInt)|\(patternFloat)|[csp])"
		return try! NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
	}()
	
	// "I give %d apples to %@" --> [.int, .string]
	static func placeholders(from formatString: String) throws -> [(PlaceholderType, Int?)] {
		let range = NSRange(formatString.startIndex..<formatString.endIndex, in: formatString)
		
		let placeholders: [(PlaceholderType, Int?)] = formatTypesRegEx.matches(in: formatString, options: [], range: range).compactMap { (match) in
			if let typeRange = Range(match.range(withName: "type"), in: formatString),
				let placeholderType = PlaceholderType(String(formatString[typeRange])) {
				var position: Int?
				if let locationRange = Range(match.range(withName: "position"), in: formatString) {
					position = Int(formatString[locationRange])
				}
				
				return (placeholderType, position)
			}
			// TODO: throw when nil
			return nil
		}
		
		return placeholders
	}
	
	static func orderedPlaceholders(from formatString: String) throws -> [PlaceholderType] {
		let unsorted = try placeholders(from: formatString)
		var sorted = Array(repeating: PlaceholderType.unknown, count: unsorted.count)
		for (index, element) in unsorted.enumerated() {
			let actualIndex = element.1?.advanced(by: -1) ?? index
			sorted[actualIndex] = element.0
		}
		return sorted
	}
}
