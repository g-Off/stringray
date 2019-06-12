//
//  StringsTable+Entry.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-09.
//

import Foundation

extension StringsTable {
	public struct Entry: Codable, Hashable, CustomStringConvertible {
		public struct Location: Codable {
			var comment: Int? = nil
			var line: Int = NSNotFound
		}
		
		var location: Location? = nil
		var comment: String? = nil
		var key: String = ""
		var value: String = ""
		
		public var description: String {
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
