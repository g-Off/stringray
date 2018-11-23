//
//  Reporter.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-20.
//

import Foundation

protocol Reporter {
	func generateReport<Target: TextOutputStream>(for violations: [LintRuleViolation], to outputStream: inout Target)
}
