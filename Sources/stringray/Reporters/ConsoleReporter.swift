//
//  ConsoleReporter.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-20.
//

import Foundation
import RayGun
import SwiftyTextTable

struct ConsoleReporter: Reporter {
	func generateReport<Target: TextOutputStream>(for violations: [LintRuleViolation], to outputStream: inout Target) {
		outputStream.write(violations.renderTextTable())
	}
}

extension LintRuleViolation: TextTableRepresentable {
	public static var columnHeaders: [String] {
		return ["Locale", "Location", "Severity", "Reason"]
	}
	
	public var tableValues: [CustomStringConvertible] {
		return [locale.identifier, location, severity, reason]
	}
}
