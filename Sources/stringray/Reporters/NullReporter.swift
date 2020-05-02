//
//  NullReporter.swift
//  
//
//  Created by Geoffrey Foster on 2020-03-08.
//

import Foundation
import SillyString

struct NullReporter: Reporter {
	func generateReport<Target: TextOutputStream>(for rule: RuleInfo, violations: [LintRuleViolation], to outputStream: inout Target) {
		
	}
}
