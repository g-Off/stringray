//
//  OrderedSet.swift
//  stringray
//
//  Created by Geoffrey Foster on 2018-11-03.
//

import Foundation

public struct OrderedSet<Element: Hashable>: Hashable, ExpressibleByArrayLiteral {
	public typealias ArrayLiteralElement = Element
	public typealias Index = Int
	
	private var orderedStorage: [Element] = []
	private var storage: Set<Element> = []
	
	public init(arrayLiteral elements: OrderedSet.ArrayLiteralElement...) {
		self.init(array: elements)
	}
	
	public init(_ array: [Element]) {
		self.init(array: array)
	}
	
	public init(array: [Element]) {
		for element in array {
			append(element)
		}
	}
	
	public init() {
		orderedStorage = []
		storage = []
	}
	
	public func contains(_ element: Element) -> Bool {
		return storage.contains(element)
	}
	
	public func contains(where predicate: (Element) throws -> Bool) rethrows -> Bool {
		return try storage.contains(where: predicate)
	}
	
	public var isEmpty: Bool {
		return storage.isEmpty
	}
}

extension OrderedSet: SetAlgebra {
	@discardableResult
	public mutating func insert(_ newMember: Element) -> (inserted: Bool, memberAfterInsert: Element) {
		let result = storage.insert(newMember)
		if result.inserted {
			orderedStorage.append(newMember)
		}
		return result
	}
	
	@discardableResult
	public mutating func update(with newMember: Element) -> Element? {
		if contains(newMember), let index = orderedStorage.firstIndex(of: newMember) {
			orderedStorage[index] = newMember
		}
		let result = storage.update(with: newMember)
		if result == nil {
			orderedStorage.append(newMember)
		}
		return result
	}
	
	@discardableResult
	public mutating func remove(_ member: Element) -> Element? {
		guard let index = orderedStorage.firstIndex(of: member) else { return nil }
		orderedStorage.remove(at: index)
		storage.remove(member)
		return member
	}
	
	public func union(_ other: OrderedSet<Element>) -> OrderedSet<Element> {
		var newSet = self
		newSet.formUnion(other)
		return newSet
	}
	
	public mutating func formUnion(_ other: OrderedSet<Element>) {
		for element in other {
			append(element)
		}
	}
	
	public func intersection(_ other: OrderedSet<Element>) -> OrderedSet<Element> {
		var newSet = self
		newSet.formIntersection(other)
		return newSet
	}
	
	public mutating func formIntersection(_ other: OrderedSet<Element>) {
		for item in self where !other.contains(item) {
			remove(item)
		}
	}
	
	public func symmetricDifference(_ other: OrderedSet<Element>) -> OrderedSet<Element> {
		var newSet = self
		newSet.formSymmetricDifference(other)
		return newSet
	}
	
	public mutating func formSymmetricDifference(_ other: OrderedSet<Element>) {
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
	public init(from decoder: Decoder) throws {
		var container = try decoder.unkeyedContainer()
		while !container.isAtEnd {
			let element = try container.decode(Element.self)
			insert(element)
		}
	}
	
	public func encode(to encoder: Encoder) throws {
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
	public mutating func sort(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows {
		try orderedStorage.sort(by: areInIncreasingOrder)
	}
	
	public mutating func append(_ newElement: Element) {
		insert(newElement, at: endIndex)
	}
	
	public mutating func insert(_ newElement: Element, at index: Index) {
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
	
	public subscript(index: Index) -> Element {
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
	
	public var startIndex: Index {
		return orderedStorage.startIndex
	}
	
	public var endIndex: Index {
		return orderedStorage.endIndex
	}
	
	public func index(after i: Index) -> Index {
		return i + 1
	}
}
