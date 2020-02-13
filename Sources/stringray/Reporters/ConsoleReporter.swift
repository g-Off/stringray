//
//  ConsoleReporter.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-20.
//

import Foundation
import SillyString
import SwiftyTextTable

struct ConsoleReporter: Reporter {
	func generateReport<Target: TextOutputStream>(for rule: RuleInfo, violations: [LintRuleViolation], to outputStream: inout Target) {
		outputStream.write(TextTable(objects: violations, header: rule.name).render())
	}
}

extension LintRuleViolation: TextTableRepresentable {
	public static var columnHeaders: [String] {
		return ["Locale", "Location", "Severity", "Reason"]
	}
	
	public var tableValues: [CustomStringConvertible] {
		return [locale, location ?? "<unknown>", severity, reason]
	}
}
