//
//  Stringray.swift
//  
//
//  Created by Geoffrey Foster on 2020-02-27.
//

import Foundation
import ArgumentParser

struct Stringray: ParsableCommand {
	static var configuration = CommandConfiguration(
        abstract: "Deal with your localized string resources.",
		subcommands: [
            Copy.self,
            Delete.self,
            Lint.self,
            Move.self,
//            Rename.self,
            Sort.self,
            VersionCommand.self
        ]
	)
}
