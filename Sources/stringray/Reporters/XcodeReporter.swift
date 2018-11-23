//
//  XcodeReporter.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-21.
//

import Foundation

struct XcodeReporter: Reporter {
	func generateReport<Target: TextOutputStream>(for violations: [LintRuleViolation], to outputStream: inout Target) {
		for violation in violations {
			outputStream.write(violation.xcode)
		}
	}
}

fileprivate extension LintRuleViolation {
	/// Outputs in an Xcode compatible way
	/// - {full_path_to_file}{:line}{:character}: {error,warning}: {content}
	var xcode: String {
		var output = location.file.path
		if let line = location.line {
			output.append(":\(line)")
		}
		output.append(": \(severity.rawValue): \(reason)\n")
		return output
	}
}
