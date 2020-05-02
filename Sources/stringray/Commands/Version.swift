//
//  Version.swift
//  
//
//  Created by Geoffrey Foster on 2020-03-05.
//

import Foundation
import ArgumentParser
import Version

@available(macOS 10.15, *)
struct VersionCommand: ParsableCommand {
	static let configuration = CommandConfiguration(commandName: "version", abstract: "Prints the current version.")
	func run() throws {
		if let bundleVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
			let version = Version(bundleVersion) {
			print(version)
		}
	}
}
