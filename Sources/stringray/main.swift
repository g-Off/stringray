//
//  main.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-02.
//  Copyright © 2018 g-Off.net. All rights reserved.
//

import Foundation
import Utility
import CommandRegistry
import Yams
import RayGun

extension Linter.Config {
	public init(url: Foundation.URL) throws {
		let string = try String(contentsOf: url, encoding: .utf8)
		self = try YAMLDecoder().decode(Linter.Config.self, from: string, userInfo: [:])
	}
}

var registry = Registry(usage: "<command> <options>", overview: "", version: Version.current)
registry.register(command: MoveCommand.self)
registry.register(command: CopyCommand.self)
registry.register(command: SortCommand.self)
registry.register(command: RenameCommand.self)
registry.register(command: LintCommand.self)
registry.run()
