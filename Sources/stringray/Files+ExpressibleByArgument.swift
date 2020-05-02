//
//  Files+ExpressibleByArgument.swift
//  
//
//  Created by Geoffrey Foster on 2020-02-27.
//

import Files
import ArgumentParser

extension File: ExpressibleByArgument {
	public init?(argument: String) {
		try? self.init(path: argument)
	}
}

extension Folder: ExpressibleByArgument {
	public init?(argument: String) {
		try? self.init(path: argument)
	}
}
