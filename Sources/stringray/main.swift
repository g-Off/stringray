//
//  main.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-02.
//  Copyright © 2018 g-Off.net. All rights reserved.
//

import Foundation
import SillyString

let running = false

#if testing
Stringray.main()
#else
//FileManager.default.changeCurrentDirectoryPath(...)

var additionalArgs: [String] = []

//additionalArgs = ["sort", "--help"]
//additionalArgs = ["copy", "--help"]
//additionalArgs = ["lint", "--help"]
additionalArgs = ["version"]

var args = CommandLine.arguments.dropFirst()
Stringray.main(args + additionalArgs)

#endif
