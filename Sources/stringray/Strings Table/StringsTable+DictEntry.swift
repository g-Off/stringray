//
//  StringsTable+DictEntry.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-09.
//

import Foundation

extension StringsTable {
	struct DictEntry: Codable, Hashable {
		private struct _DictKey: CodingKey, Equatable {
			var stringValue: String
			var intValue: Int?
			
			init?(stringValue: String) {
				self.stringValue = stringValue
				self.intValue = nil
			}
			
			init?(intValue: Int) {
				self.stringValue = "\(intValue)"
				self.intValue = intValue
			}
			
			static let localizedFormatKey = _DictKey(stringValue: "NSStringLocalizedFormatKey")!
			static func pluralization(_ key: String) -> _DictKey {
				return _DictKey(stringValue: key)!
			}
		}
		struct PluralizationRule: Codable, Hashable {
			private enum CodingKeys: String, CodingKey {
				case zero, one, two, few, many, other
				case specType = "NSStringFormatSpecTypeKey"
				case valueType = "NSStringFormatValueTypeKey"
			}
			private static let pluralRuleType = "NSStringPluralRuleType"
			// CodingKeys should have a key/value pair of NSStringFormatSpecTypeKey/NSStringPluralRuleType
			let zero: String?
			let one: String?
			let two: String?
			let few: String?
			let many: String?
			let other: String
			
			let valueType: String
			
			init(from decoder: Decoder) throws {
				let container = try decoder.container(keyedBy: CodingKeys.self)
				//precondition(try container.decode(String.self, forKey: .formatSpecType) == type(of: self).pluralRuleType)
				self.zero = try container.decodeIfPresent(String.self, forKey: .zero)
				self.one = try container.decodeIfPresent(String.self, forKey: .one)
				self.two = try container.decodeIfPresent(String.self, forKey: .two)
				self.few = try container.decodeIfPresent(String.self, forKey: .few)
				self.many = try container.decodeIfPresent(String.self, forKey: .many)
				self.other = try container.decode(String.self, forKey: .other)
				self.valueType = try container.decode(String.self, forKey: .valueType)
			}
			
			func encode(to encoder: Encoder) throws {
				var container = encoder.container(keyedBy: CodingKeys.self)
				try container.encodeIfPresent(zero, forKey: .zero)
				try container.encodeIfPresent(one, forKey: .one)
				try container.encodeIfPresent(two, forKey: .two)
				try container.encodeIfPresent(few, forKey: .few)
				try container.encodeIfPresent(many, forKey: .many)
				try container.encode(other, forKey: .other)
				try container.encode(type(of: self).pluralRuleType, forKey: .specType)
				try container.encode(valueType, forKey: .valueType)
			}
		}
		
		let formatKey: String
		let pluralizations: [String: PluralizationRule]
		
		init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: _DictKey.self)
			self.formatKey = try container.decode(String.self, forKey: _DictKey.localizedFormatKey)
			let allKeys = container.allKeys.filter {
				return $0 != _DictKey.localizedFormatKey
			}
			let elements: [(String, PluralizationRule)] = try allKeys.map { (key) in
				let pluralization = try container.decode(PluralizationRule.self, forKey: key)
				return (key.stringValue, pluralization)
			}
			self.pluralizations = Dictionary(elements, uniquingKeysWith: { (lhs, _) in return lhs })
		}
		
		func encode(to encoder: Encoder) throws {
			var container = encoder.container(keyedBy: _DictKey.self)
			try container.encode(formatKey, forKey: _DictKey.localizedFormatKey)
			try pluralizations.forEach {
				try container.encode($0.value, forKey: _DictKey(stringValue: $0.key)!)
			}
		}
	}
}
