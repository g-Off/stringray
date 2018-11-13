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
}

extension Array where Element == Match {
	func matches(key: String) -> Bool {
		return contains {
			return $0.matches(key: key)
		}
	}
}
