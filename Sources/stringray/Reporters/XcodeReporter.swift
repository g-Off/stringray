//
//  XcodeReporter.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-21.
//

import Foundation
import SillyString

struct XcodeReporter: Reporter {
	func generateReport<Target: TextOutputStream>(for rule: RuleInfo, violations: [LintRuleViolation], to outputStream: inout Target) {
		for violation in violations {
			outputStream.write(violation.xcode)
		}
	}
}

fileprivate extension LintRuleViolation {
	/// Outputs in an Xcode compatible way
	/// - {full_path_to_file}{:line}{:character}: {error,warning}: {content}
	var xcode: String {
		guard let location = location else { return "<unknown>" }
		var output = location.file
		if let line = location.line {
			output.append(":\(line)")
		}
		output.append(": \(severity.rawValue): \(reason)\n")
		return output
	}
}
