//
//  LintCommand.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-07.
//

import Foundation
import CommandRegistry
import Basic
import Utility
import RayGun
import XcodeProject
import SwiftyTextTable

struct LintCommand: Command {
	private struct Arguments {
		var inputFile: [AbsolutePath] = []
		var listRules: Bool = false
		var configFile: AbsolutePath?
	}
	
	private struct LintInput: Hashable {
		let resourceURL: Foundation.URL
		let tableName: String
		let locale: Locale
	}
	
	let command: String = "lint"
	let overview: String = "Checks for warnings or errors on the given strings table."
	
	private let binder: ArgumentBinder<Arguments>
	
	init(parser: ArgumentParser) {
		binder = ArgumentBinder<Arguments>()
		let subparser = parser.add(subparser: command, overview: overview)
		
		let filesUsage = "Specify a list of file paths to the string files to run lint on; If omitted, this will default to the current folder"
		let files = subparser.add(positional: "files", kind: [PathArgument].self, optional: true, usage: filesUsage, completion: .filename)
		binder.bind(positional: files) { (arguments, files) in
			arguments.inputFile = files.map { $0.path }
		}
		
		let listRules = subparser.add(option: "--list", shortName: "-l", kind: Bool.self, usage: "List available rules and default configuration", completion: .none)
		binder.bind(option: listRules) { (arguments, listRules) in
			arguments.listRules = listRules
		}
		
		let configFileOption = subparser.add(option: "--config", shortName: "-c", kind: PathArgument.self, usage: "Configuration YAML file", completion: .filename)
		binder.bind(option: configFileOption) { (arguments, configFile) in
			arguments.configFile = configFile.path
		}
	}
	
	func run(with arguments: ArgumentParser.Result) throws {
		var commandArgs = Arguments()
		try binder.fill(parseResult: arguments, into: &commandArgs)
		
		if commandArgs.listRules {
			listRules()
			return
		}
		
		let config: Linter.Config
		if let configFile = commandArgs.configFile ?? localFileSystem.currentWorkingDirectory?.appending(component: Linter.fileName), localFileSystem.exists(configFile) {
			let url = URL(fileURLWithPath: configFile.asString)
			config = try Linter.Config(url: url)
		} else {
			config = Linter.Config()
		}
		
		let lintInput: [LintInput]
		var reporter: Reporter = ConsoleReporter()
		if commandArgs.inputFile.isEmpty {
			let environment = ProcessInfo.processInfo.environment
			if let xcodeInput = try inputsFromXcode(environment: environment) {
				lintInput = xcodeInput
				reporter = XcodeReporter()
			} else if let currentWorkingDirectory = localFileSystem.currentWorkingDirectory {
				lintInput = inputs(from: [currentWorkingDirectory])
			} else {
				lintInput = []
			}
		} else {
			lintInput = inputs(from: commandArgs.inputFile)
		}
		try lint(inputs: lintInput, reporter: reporter, config: config)
	}
	
	private func inputs(from files: [AbsolutePath]) -> [LintInput] {
		let inputs: [LintInput] = files.filter {
			localFileSystem.exists($0) && localFileSystem.isFile($0)
			}.map {
				URL(fileURLWithPath: $0.asString)
			}.compactMap {
				guard let tableName = $0.tableName else { return nil }
				guard let locale = $0.locale else { return nil }
				return LintInput(resourceURL: $0.resourceDirectory, tableName: tableName, locale: locale)
		}
		return inputs
	}
	
	private func inputsFromXcode(environment: [String: String]) throws -> [LintInput]? {
		guard let projectPath = environment["PROJECT_FILE_PATH"],
			let targetName = environment["TARGETNAME"],
			let infoPlistPath = environment["INFOPLIST_FILE"],
			let sourceRoot = environment["SOURCE_ROOT"] else {
				return nil
		}
		
		let projectURL = URL(fileURLWithPath: projectPath)
		let sourceRootURL = URL(fileURLWithPath: sourceRoot)
		let infoPlistURL = URL(fileURLWithPath: infoPlistPath, relativeTo: sourceRootURL)
		let data = try Data(contentsOf: infoPlistURL)
		guard let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any], let base = plist["CFBundleDevelopmentRegion"] as? String else {
			return nil
		}
		let locale = Locale(identifier: base)
		
		let projectFile = try ProjectFile(url: projectURL)
		guard let target = projectFile.project.target(named: targetName) else { return nil }
		guard let resourcesBuildPhase = target.resourcesBuildPhase else { return nil }
		let variantGroups = resourcesBuildPhase.files.compactMap { $0.fileRef as? PBXVariantGroup }.filter {
			guard let name = $0.name else { return false }
			return name.hasSuffix(".strings") || name.hasSuffix(".stringsdict")
		}
		let variantGroupsFiles = variantGroups.flatMap {
			$0.children.compactMap { $0 as? PBXFileReference }.compactMap { $0.url }.filter { $0.pathExtension == "strings" || $0.pathExtension == "stringsdict" }
		}
		let allInputs: [LintInput] = variantGroupsFiles.compactMap {
			guard let tableName = $0.tableName else { return nil }
			return LintInput(resourceURL: $0.resourceDirectory, tableName: tableName, locale: locale)
		}
		let uniqueInputs = Set(allInputs)
		return Array(uniqueInputs)
	}
	
	private func listRules() {
		let linter = Linter(reporter: ConsoleReporter())
		let rules = linter.rules
		let columns = [
			TextTableColumn(header: "id"),
			TextTableColumn(header: "name"),
			TextTableColumn(header: "description")
		]
		var table = TextTable(columns: columns)
		rules.forEach {
			table.addRow(values:
				[
					$0.info.identifier,
					$0.info.name,
					$0.info.description
				]
			)
		}
		print(table.render())
	}
	
	private func lint(inputs: [LintInput], reporter: Reporter, config: Linter.Config) throws {
		var loader = StringsTableLoader()
		loader.options = [.lineNumbers]
		let linter = Linter(reporter: reporter, config: config)
		var violations: [LintRuleViolation] = []
		
		try inputs.forEach {
			print("Linting: \($0.tableName)")
			let table = try loader.load(url: $0.resourceURL, name: $0.tableName, base: $0.locale)
			do {
				try linter.report(on: table, url: $0.resourceURL)
				try loader.writeCache(table: table, baseURL: $0.resourceURL)
			} catch let error as Linter.Error {
				violations.append(contentsOf: error.violations)
			}
		}
		if !violations.isEmpty {
			throw Linter.Error(violations)
		}
	}
}
