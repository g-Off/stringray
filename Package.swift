// swift-tools-version:4.2
import PackageDescription

let package = Package(
	name: "stringray",
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
		.package(url: "https://github.com/g-Off/XcodeProject.git", from: "0.4.0"),
		.package(url: "https://github.com/g-Off/CommandRegistry.git", .branch("master")),
		.package(url: "https://github.com/apple/swift-package-manager.git", from: "0.3.0")
	],
	targets: [
		.target(
			name: "stringray",
			dependencies: [
				"CommandRegistry",
				"RayGun",
				"SwiftyTextTable"
			]
		),
		.target(
			name: "RayGun",
			dependencies: [
				"Utility",
				"Yams",
				"XcodeProject"
			]
		),
		.testTarget(
			name: "stringrayTests",
			dependencies: ["RayGun"]),
		]
)
