//
//  Reporter.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-20.
//

import Foundation

public protocol Reporter {
	func generateReport<Target: TextOutputStream>(for rule: RuleInfo, violations: [LintRuleViolation], to outputStream: inout Target)
}
