//
//  main.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-02.
//  Copyright © 2018 g-Off.net. All rights reserved.
//

import Foundation

var registry = CommandRegistry(usage: "<command> <options>", overview: "")
registry.register(command: MoveCommand.self)
registry.register(command: SortCommand.self)
registry.register(command: LintCommand.self)
registry.run()
