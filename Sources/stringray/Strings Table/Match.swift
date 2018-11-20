//
//  Match.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-02.
//

import Foundation

enum Match {
	case prefix(String)
	case regex(NSRegularExpression)
	
	func matches(key: String) -> Bool {
		switch self {
		case .prefix(let prefix):
			return key.hasPrefix(prefix)
		case .regex(_): // TODO: support this eventually
			return false
		}
	}
	
	func replacing(with newPrefix: String, in string: String) -> String? {
		switch self {
		case .prefix(let prefix):
			guard let range = string.range(of: prefix) else { return nil }
			return string.replacingCharacters(in: range, with: newPrefix)
		default:
			return nil
		}
	}
}

extension Array where Element == Match {
	func matches(key: String) -> Bool {
		return contains {
			return $0.matches(key: key)
		}
	}
}
