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

CI builds and runs the test suite on macOS, iOS Simulator, Linux, Windows and Android on every push.

- **macOS 12+, iOS 13+, tvOS 13+, watchOS 6+** — libxml2 ships with the OS SDKs, nothing to install.
- **Linux** — install `libxml2-dev` and `pkg-config`.
- **Windows** — install libxml2 via vcpkg, then pass its paths per invocation (do *not* export `INCLUDE`/`LIB` — that suppresses the toolchain's MSVC auto-detection):

  ```powershell
  vcpkg install libxml2:x64-windows
  swift build -Xcc -IC:\vcpkg\installed\x64-windows\include\libxml2 `
              -Xcc -IC:\vcpkg\installed\x64-windows\include `
              -Xlinker -libpath:C:\vcpkg\installed\x64-windows\lib
  ```

  `C:\vcpkg\installed\x64-windows\bin` must be on `PATH` at runtime so `libxml2.dll` loads.
- **Android** — the official Swift Android SDK bundles a full `libxml2.a` (HTML parser included) but no development headers. The `build-android` job in [swift.yml](.github/workflows/swift.yml) shows the working recipe: remove the host's libxml2 dev files, extract Debian's ICU-free libxml2 headers, and link the SDK's own archive with `-lxml2 -lz`.

## Heritage

This parser is the modern descendant of `DTHTMLParser` (of DTFoundation lineage), rewritten in Swift with an async event stream. It was extracted from [SwiftText](https://github.com/Cocoanetics/SwiftText) into its own package so that consumers like [DTCoreText](https://github.com/Cocoanetics/DTCoreText) and SwiftText itself can share it without dragging in unrelated dependencies. The git history of the parser sources travels with it.

An XML SAX module along the same lines is a natural future addition — hence the package name.

## License

MIT — see [LICENSE](LICENSE).
