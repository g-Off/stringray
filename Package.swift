// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "stringray",
	dependencies: [
		.package(url: "https://github.com/apple/swift-package-manager.git", from: "0.3.0")
	],
	targets: [
		.target(
			name: "stringray",
			dependencies: ["Utility"]),
		.testTarget(
			name: "stringrayTests",
			dependencies: ["stringray"]),
		]
)
