//
//  StringsTable+Entry.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-09.
//

import Foundation

extension StringsTable {
	struct Entry: Codable, Hashable {
		static func load(from url: URL) throws -> OrderedSet<Entry> {
			func lineNumber(scanLocation: Int, newlineLocations: [Int]) -> Int {
				var lastIndex = 0
				for (index, newlineLocation) in newlineLocations.enumerated() {
					if newlineLocation > scanLocation {
						break
					}
					lastIndex = index
				}
				return lastIndex
			}
			
			let regex = try NSRegularExpression(pattern: "\"(?<key>.*)\"\\s*=\\s*\"(?<value>.*)\"", options: [])
			let baseString = try String(contentsOf: url)
			
			var newlineLocations: [Int] = []
			baseString.enumerateSubstrings(in: baseString.startIndex..<baseString.endIndex, options: [.byLines, .substringNotRequired]) { (_, substringRange, _, stop) in
				newlineLocations.append(substringRange.lowerBound.encodedOffset)
			}
			
			var entries: [Entry] = []
			let scanner = Scanner(string: baseString)
			while !scanner.isAtEnd {
				var comment: Entry.Comment?
				if scanner.scanString("/*", into: nil) {
					var scannedComment: NSString?
					let location = lineNumber(scanLocation: scanner.scanLocation, newlineLocations: newlineLocations)
					scanner.scanUpTo("*/\n", into: &scannedComment)
					scanner.scanString("*/\n", into: nil)
					if let scannedComment = scannedComment?.trimmingCharacters(in: CharacterSet.whitespaces) as String? {
						comment = Entry.Comment(line: location, value: scannedComment)
					}
				}
				scanner.scanCharacters(from: .whitespacesAndNewlines, into: nil)
				var scannedString: NSString?
				scanner.scanUpTo(";\n", into: &scannedString)
				scanner.scanString(";\n", into: nil)
				let keyValueLocation = lineNumber(scanLocation: scanner.scanLocation, newlineLocations: newlineLocations)
				
				if let scannedString = scannedString {
					regex.enumerateMatches(in: scannedString as String, options: [], range: NSRange(location: 0, length: scannedString.length)) { (result, flags, done) in
						guard let result = result else { return }
						let key = scannedString.substring(with: result.range(withName: "key"))
						let value = scannedString.substring(with: result.range(withName: "value"))
						let keyedValue = Entry.KeyedValue(line: keyValueLocation, key: key, value: value)
						let entry = Entry(comment: comment, keyedValue: keyedValue)
						entries.append(entry)
					}
				}
			}
			return OrderedSet(entries)
		}
		
		struct Comment: Codable, Hashable, CustomStringConvertible {
			let line: Int
			let value: String
			
			var description: String {
				return "/* \(value) */"
			}
		}
		struct KeyedValue: Codable, Hashable, CustomStringConvertible {
			let line: Int
			let key: String
			let value: String
			
			var description: String {
				return "\"\(key)\" = \"\(value)\";"
			}
		}
		
		let comment: Comment?
		let keyedValue: KeyedValue
		
		public static func ==(lhs: Entry, rhs: Entry) -> Bool {
			return lhs.keyedValue.key == rhs.keyedValue.key
		}
		
		public func hash(into hasher: inout Hasher) {
			hasher.combine(keyedValue.key)
		}
	}
}
