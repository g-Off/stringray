//
//  StringsTable+Entry.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-09.
//

import Foundation

extension StringsTable {
	struct Entry: Codable, Hashable, CustomStringConvertible {
		struct LoadOptions: OptionSet {
			public private(set) var rawValue: UInt
			public init(rawValue: UInt) { self.rawValue = rawValue }
			
			public static let lineNumbers = LoadOptions(rawValue: 1 << 0)
		}
		
		static func load(from url: URL, options: LoadOptions) throws -> OrderedSet<Entry> {
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
			if options.contains(.lineNumbers) {
				baseString.enumerateSubstrings(in: baseString.startIndex..<baseString.endIndex, options: [.byLines, .substringNotRequired]) { (_, substringRange, _, stop) in
					newlineLocations.append(substringRange.lowerBound.encodedOffset)
				}
			}
			
			var entries: [Entry] = []
			let scanner = Scanner(string: baseString)
			while !scanner.isAtEnd {
				var entry = Entry()
				if options.contains(.lineNumbers) {
					entry.location = Location()
				}
				if scanner.scanString("/*", into: nil) {
					var scannedComment: NSString?
					if options.contains(.lineNumbers) {
						entry.location?.comment = lineNumber(scanLocation: scanner.scanLocation, newlineLocations: newlineLocations)
					}
					scanner.scanUpTo("*/\n", into: &scannedComment)
					scanner.scanString("*/\n", into: nil)
					if let scannedComment = scannedComment?.trimmingCharacters(in: CharacterSet.whitespaces) as String? {
						entry.comment = scannedComment
					}
				}
				scanner.scanCharacters(from: .whitespacesAndNewlines, into: nil)
				var scannedString: NSString?
				scanner.scanUpTo(";\n", into: &scannedString)
				scanner.scanString(";\n", into: nil)
				if options.contains(.lineNumbers) {
					entry.location?.line = lineNumber(scanLocation: scanner.scanLocation, newlineLocations: newlineLocations)
				}
				
				if let scannedString = scannedString {
					regex.enumerateMatches(in: scannedString as String, options: [], range: NSRange(location: 0, length: scannedString.length)) { (result, flags, done) in
						guard let result = result else { return }
						entry.key = scannedString.substring(with: result.range(withName: "key"))
						entry.value = scannedString.substring(with: result.range(withName: "value"))
						entries.append(entry)
					}
				}
			}
			return OrderedSet(entries)
		}
		
		struct Location: Codable {
			var comment: Int? = nil
			var line: Int = NSNotFound
		}
		
		var location: Location? = nil
		var comment: String? = nil
		var key: String = ""
		var value: String = ""
		
		var description: String {
			var string = ""
			if let comment = comment {
				string.append("/* \(comment) */\n")
			}
			string.append("\"\(key)\" = \"\(value)\";")
			return string
		}
		
		public static func ==(lhs: Entry, rhs: Entry) -> Bool {
			return lhs.key == rhs.key
		}
		
		public func hash(into hasher: inout Hasher) {
			hasher.combine(key)
		}
	}
}
