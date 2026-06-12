// swift-tools-version:6.1

import PackageDescription

// libxml2 system library:
//   - On Linux: resolved via pkg-config "libxml-2.0" which provides
//     -I/usr/include/libxml2 and -lxml2.  CHTMLParser depends on CLibXML2
//     so those flags propagate automatically.
//   - On macOS: libxml2 is part of the SDK; link directly with -lxml2.
//   - On Windows: installed via vcpkg; headers/libs found via INCLUDE/LIB env vars.
#if os(Linux)
let cHTMLParserDeps: [Target.Dependency] = [.target(name: "CLibXML2")]
let cHTMLParserLinker: [LinkerSetting] = []
let xmlSystemTargets: [Target] = [
	.systemLibrary(
		name: "CLibXML2",
		pkgConfig: "libxml-2.0",
		providers: [.apt(["libxml2-dev"])]
	),
]
#elseif os(Windows)
let cHTMLParserDeps: [Target.Dependency] = []
let cHTMLParserLinker: [LinkerSetting] = [.linkedLibrary("libxml2")]
let xmlSystemTargets: [Target] = []
#else
let cHTMLParserDeps: [Target.Dependency] = []
let cHTMLParserLinker: [LinkerSetting] = [.linkedLibrary("xml2")]
let xmlSystemTargets: [Target] = []
#endif

let package = Package(
	name: "XMLKit",
	platforms: [
		.macOS(.v12),
		.iOS(.v13),
		.tvOS(.v13),
		.watchOS(.v6),
	],
	products: [
		.library(
			name: "HTMLParser",
			targets: ["HTMLParser"]),
	],
	targets: [
		.target(
			name: "CHTMLParser",
			dependencies: cHTMLParserDeps,
			path: "Sources/CHTMLParser",
			publicHeadersPath: "include",
			linkerSettings: cHTMLParserLinker
		),
		.target(
			name: "HTMLParser",
			dependencies: ["CHTMLParser"],
			path: "Sources/HTMLParser"
		),
		.testTarget(
			name: "HTMLParserTests",
			dependencies: ["HTMLParser"],
			path: "Tests/HTMLParserTests"
		),
	] + xmlSystemTargets
)
