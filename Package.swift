// swift-tools-version:4.2
import PackageDescription

let package = Package(
	name: "stringray",
	dependencies: [
		.package(url: "https://github.com/jpsim/Yams.git", from: "1.0.1"),
		.package(url: "https://github.com/scottrhoyt/SwiftyTextTable.git", from: "0.5.0"),
		.package(url: "https://github.com/g-Off/XcodeProject.git", from: "0.4.0"),
		.package(url: "https://github.com/g-Off/CommandRegistry.git", .branch("master"))
	],
	targets: [
		.target(
			name: "stringray",
			dependencies: [
				"Yams",
				"SwiftyTextTable",
				"XcodeProject",
				"CommandRegistry"
			]
		),
		.testTarget(
			name: "stringrayTests",
			dependencies: ["stringray"]),
		]
)
