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
}
