//
//  OrderedSet.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-03.
//

import Foundation

struct OrderedSet<Element: Hashable>: Hashable, ExpressibleByArrayLiteral {
	typealias ArrayLiteralElement = Element
	typealias Index = Int
	
	private var orderedStorage: [Element] = []
	private var storage: Set<Element> = []
	
	init(arrayLiteral elements: OrderedSet.ArrayLiteralElement...) {
		self.init(array: elements)
	}
	
	init(_ array: [Element]) {
		self.init(array: array)
	}
	
	init(array: [Element]) {
		for element in array {
			append(element)
		}
	}
	
	init() {
		orderedStorage = []
		storage = []
	}
	
	func contains(_ element: Element) -> Bool {
		return storage.contains(element)
	}
	
	func contains(where predicate: (Element) throws -> Bool) rethrows -> Bool {
		return try storage.contains(where: predicate)
	}
	
	var isEmpty: Bool {
		return storage.isEmpty
	}
}

extension OrderedSet: SetAlgebra {
	@discardableResult
	mutating func insert(_ newMember: Element) -> (inserted: Bool, memberAfterInsert: Element) {
		let result = storage.insert(newMember)
		if result.inserted {
			orderedStorage.append(newMember)
		}
		return result
	}
	
	@discardableResult
	mutating func update(with newMember: Element) -> Element? {
		if contains(newMember), let index = orderedStorage.index(of: newMember) {
			orderedStorage[index] = newMember
		}
		let result = storage.update(with: newMember)
		if result == nil {
			orderedStorage.append(newMember)
		}
		return result
	}
	
	@discardableResult
	mutating func remove(_ member: Element) -> Element? {
		guard let index = orderedStorage.index(of: member) else { return nil }
		orderedStorage.remove(at: index)
		storage.remove(member)
		return member
	}
	
	func union(_ other: OrderedSet<Element>) -> OrderedSet<Element> {
		var newSet = self
		newSet.formUnion(other)
		return newSet
	}
	
	mutating func formUnion(_ other: OrderedSet<Element>) {
		for element in other {
			append(element)
		}
	}
	
	func intersection(_ other: OrderedSet<Element>) -> OrderedSet<Element> {
		var newSet = self
		newSet.formIntersection(other)
		return newSet
	}
	
	mutating func formIntersection(_ other: OrderedSet<Element>) {
		for item in self where !other.contains(item) {
			remove(item)
		}
	}
	
	func symmetricDifference(_ other: OrderedSet<Element>) -> OrderedSet<Element> {
		var newSet = self
		newSet.formSymmetricDifference(other)
		return newSet
	}
	
	mutating func formSymmetricDifference(_ other: OrderedSet<Element>) {
		for member in other {
			if contains(member) {
				remove(member)
			} else {
				insert(member)
			}
		}
	}
}

extension OrderedSet: Codable where Element: Codable {
	init(from decoder: Decoder) throws {
		var container = try decoder.unkeyedContainer()
		while !container.isAtEnd {
			let element = try container.decode(Element.self)
			insert(element)
		}
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.unkeyedContainer()
		try container.encode(contentsOf: orderedStorage)
	}
}

extension OrderedSet: RandomAccessCollection {
	
}

extension OrderedSet: Sequence {
//	func makeIterator() -> IndexingIterator<OrderedSet<Element>> {
//		return orderedStorage.makeIterator()
//	}
}

extension OrderedSet: MutableCollection {
	mutating func sort(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows {
		try orderedStorage.sort(by: areInIncreasingOrder)
	}
	
	mutating func append(_ newElement: Element) {
		insert(newElement, at: endIndex)
	}
	
	mutating func insert(_ newElement: Element, at index: Index) {
		guard !contains(newElement) else { return }
		storage.insert(newElement)
		orderedStorage.insert(newElement, at: index)
	}
	
	private mutating func _replace(_ newMember: Element, at index: Index) {
		let objectToReplace = orderedStorage[index]
		if newMember != objectToReplace && contains(newMember) {
			return
		}
		orderedStorage[index] = newMember
		storage.remove(objectToReplace)
		storage.insert(newMember)
	}
	
	subscript(index: Index) -> Element {
		get {
			return orderedStorage[index]
		}
		set {
			if index == endIndex {
				insert(newValue, at: index)
			} else {
				_replace(newValue, at: index)
			}
		}
	}
	
	var startIndex: Index {
		return orderedStorage.startIndex
	}
	
	var endIndex: Index {
		return orderedStorage.endIndex
	}
	
	func index(after i: Index) -> Index {
		return i + 1
	}
}
