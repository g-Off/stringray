// swift-tools-version:5.0
import PackageDescription

let package = Package(
	name: "stringray",
	platforms: [
		.macOS(.v10_14)
	],
	products: [
		.executable(
			name: "stringray",
			targets: ["stringray"]
		),
		.library(
			name: "RayGun",
			targets: ["RayGun"]
		)
	],
	dependencies: [
		.package(url: "https://github.com/jpsim/Yams.git", from: "1.0.1"),
		.package(url: "https://github.com/scottrhoyt/SwiftyTextTable.git", from: "0.5.0"),
		.package(url: "https://github.com/g-Off/XcodeProject.git", from: "0.5.0-alpha.3"),
		.package(url: "https://github.com/g-Off/CommandRegistry.git", from: "0.1.0"),
		.package(url: "https://github.com/apple/swift-package-manager.git", from: "0.3.0")
	],
	targets: [
		.target(
			name: "stringray",
			dependencies: [
				"CommandRegistry",
				"RayGun",
				"SwiftyTextTable",
				"XcodeProject",
				"Utility",
				"Yams",
			]
		),
		.target(
			name: "RayGun",
			dependencies: [
			]
		),
		.testTarget(
			name: "stringrayTests",
			dependencies: ["RayGun"]),
		]
)
