//
//  File.swift
//  
//
//  Created by Geoffrey Foster on 2020-02-09.
//

import Foundation

public struct Location {
	public let file: String
	public let line: UInt?
	public let character: UInt?
	
	public init(file: String, line: UInt? = nil, character: UInt? = nil) {
		self.file = file
		self.line = line
		self.character = character
	}
}

extension Location: Equatable {}
extension Location: Hashable {}

extension Location: CustomStringConvertible {
	public var description: String {
		var path = file
		if let line = line {
			path.append(":\(line)")
		}
		if let character = character {
			path.append(":\(character)")
		}
		return path
	}
}
