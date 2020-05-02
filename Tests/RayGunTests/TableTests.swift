//
//  TableTests.swift
//  
//
//  Created by Geoffrey Foster on 2020-02-10.
//

import XCTest
@testable import RayGun

class TableTests: XCTestCase {
	func testStringLoad() throws {
		let string = """
/* This is a sample */
"key" = "value";
"""
		XCTAssertNoThrow(try LocalizedString.parse(string: string))
	}
	
	func testStringDictLoad() throws {
		let string = """
	<?xml version="1.0" encoding="UTF-8"?>
	<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
	<plist version="1.0">
	<dict>
		<key>timeline.toast.error.tooManyCommentAttachments</key>
		<dict>
			<key>NSStringLocalizedFormatKey</key>
			<string>Comments can&apos;t have more than %1$d %#@d_num_attachments@.</string>
			<key>d_num_attachments</key>
			<dict>
				<key>NSStringFormatSpecTypeKey</key>
				<string>NSStringPluralRuleType</string>
				<key>NSStringFormatValueTypeKey</key>
				<string>d</string>
				<key>one</key>
				<string>attachment</string>
				<key>other</key>
				<string>attachments</string>
			</dict>
		</dict>
	</dict>
	</plist>
	"""
		let data = try XCTUnwrap(string.data(using: .utf8))
		XCTAssertNoThrow(try LocalizedString.load(data: data))
	}
}
