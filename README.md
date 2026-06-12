# XMLKit

Swift wrappers around libxml2's streaming SAX parsers, for Apple platforms and Linux.

The package currently ships one module, **HTMLParser** — a tolerant, async streaming HTML parser. Because libxml2 does the heavy lifting, it handles real-world malformed HTML gracefully and never builds a DOM unless you do.

## Usage

```swift
import HTMLParser

let parser = HTMLParser(data: htmlData, encoding: .utf8)

for await event in parser.parseEvents() {
    switch event {
    case .startElement(let name, let attributes):
        print("<\(name)> \(attributes)")
    case .characters(let text):
        print(text)
    case .endElement(let name):
        print("</\(name)>")
    default:
        break
    }
}
```

A delegate-based API (`HTMLParserDelegate` with `HTMLParserDelegateAdapter`) is available for callers that prefer callbacks over `AsyncStream`.

## Installation

```swift
.package(url: "https://github.com/Cocoanetics/XMLKit.git", from: "1.0.0"),
```

then add the product to your target:

```swift
.product(name: "HTMLParser", package: "XMLKit"),
```

## Platforms

- macOS 12+, iOS 13+, tvOS 13+, watchOS 6+ (libxml2 ships with the OS SDKs)
- Linux — install `libxml2-dev` and `pkg-config`
- Windows — libxml2 via vcpkg (manifest support present, not covered by CI)

## Heritage

This parser is the modern descendant of `DTHTMLParser` (of DTFoundation lineage), rewritten in Swift with an async event stream. It was extracted from [SwiftText](https://github.com/Cocoanetics/SwiftText) into its own package so that consumers like [DTCoreText](https://github.com/Cocoanetics/DTCoreText) and SwiftText itself can share it without dragging in unrelated dependencies. The git history of the parser sources travels with it.

An XML SAX module along the same lines is a natural future addition — hence the package name.

## License

MIT — see [LICENSE](LICENSE).
