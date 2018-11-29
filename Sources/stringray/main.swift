//
//  main.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-02.
//  Copyright © 2018 g-Off.net. All rights reserved.
//

import Foundation
import Utility

var registry = CommandRegistry(usage: "<command> <options>", overview: "", version: Version(0, 1, 1))
registry.register(command: MoveCommand.self)
registry.register(command: SortCommand.self)
registry.register(command: RenameCommand.self)
registry.register(command: LintCommand.self)
registry.run()
