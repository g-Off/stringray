// swift-tools-version:5.1
import PackageDescription

let package = Package(
	name: "stringray",
	platforms: [
		.macOS("10.15")
	],
	products: [
		.executable(
			name: "stringray",
			targets: ["stringray"]
		),
		.library(
			name: "RayGun",
			targets: ["RayGun"]
		),
		.library(
			name: "SillyString",
			targets: ["SillyString"]
		)
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.4"),
		.package(url: "https://github.com/jpsim/Yams.git", from: "1.0.1"),
		.package(url: "https://github.com/scottrhoyt/SwiftyTextTable.git", from: "0.5.0"),
		.package(url: "https://github.com/JohnSundell/Files.git", from: "4.0.0"),
		.package(url: "https://github.com/mxcl/Version.git", from: "1.0.0"),
		.package(url: "https://github.com/g-Off/PrintfParser.git", from: "0.1.0")
	],
	targets: [
		.target(
			name: "stringray",
			dependencies: [
				"ArgumentParser",
				"SillyString",
				"SwiftyTextTable",
				"Yams",
				"Version"
			],
			linkerSettings: [
				.unsafeFlags(["-Xlinker", "-sectcreate"], .when(platforms: [.macOS])),
				.unsafeFlags(["-Xlinker", "__TEXT"], .when(platforms: [.macOS])),
				.unsafeFlags(["-Xlinker", "__info_plist"], .when(platforms: [.macOS])),
				.unsafeFlags(["-Xlinker", "Info.plist"], .when(platforms: [.macOS]))
			]
		),
		.target(
			name: "RayGun",
			dependencies: [
				"Files"
			]
		),
		.target(
			name: "SillyString",
			dependencies: [
				"RayGun",
				"PrintfParser"
			]
		),
		.testTarget(
			name: "RayGunTests",
			dependencies: ["RayGun"]
		),
		.testTarget(
			name: "SillyStringTests",
			dependencies: ["SillyString"]
		),
//		.testTarget(
//			name: "stringrayTests",
//			dependencies: ["RayGun", "SillyString"]
//		),
	]
)
