import Testing
import Foundation
import HTMLParser

@Suite("HTMLParser")
struct HTMLParserTests
{
	private func collectEvents(parsing html: String, options: HTMLParserOptions = [.recover, .noNet, .compact, .noBlanks]) async -> [HTMLParserEvent]
	{
		let parser = HTMLParser(data: Data(html.utf8), encoding: .utf8, options: options)
		var events = [HTMLParserEvent]()

		for await event in parser.parseEvents() {
			events.append(event)
		}

		return events
	}

	private func characterEvents(in events: [HTMLParserEvent]) -> [String]
	{
		events.compactMap { event in
			if case .characters(let string) = event {
				return string
			}
			return nil
		}
	}

	@Test("Simple document produces the expected event sequence")
	func simpleDocument() async
	{
		let events = await collectEvents(parsing: "<html><body><p class=\"greeting\">Hello</p></body></html>")

		#expect(events.first == .startDocument)
		#expect(events.last == .endDocument)
		#expect(events.contains(.startElement(name: "p", attributes: ["class": "greeting"])))
		#expect(events.contains(.characters("Hello")))
		#expect(events.contains(.endElement(name: "p")))
	}

	@Test("Entities are resolved and characters accumulate into a single event")
	func entityResolution() async
	{
		let events = await collectEvents(parsing: "<p>Fish &amp; Chips</p>")

		#expect(characterEvents(in: events).contains("Fish & Chips"))
	}

	@Test("Comments are reported")
	func comments() async
	{
		let events = await collectEvents(parsing: "<p>x</p><!-- note -->")

		#expect(events.contains(.comment(" note ")))
	}

	@Test("Malformed HTML recovers and still finishes the document")
	func malformedRecovery() async
	{
		let events = await collectEvents(parsing: "<p>unclosed <b>nested")

		#expect(events.last == .endDocument)
		#expect(characterEvents(in: events).contains { $0.hasPrefix("unclosed") })
		#expect(events.contains(.startElement(name: "b", attributes: [:])))
	}

	@Test("Non-ASCII UTF-8 content survives parsing")
	func utf8Content() async
	{
		let events = await collectEvents(parsing: "<p>Grüße aus Wien</p>")

		#expect(characterEvents(in: events).contains("Grüße aus Wien"))
	}

	@Test("Parse errors surface on the error property when not recovering")
	func parserReportsLineNumbers() async
	{
		let parser = HTMLParser(data: Data("<p>Hello</p>".utf8), encoding: .utf8)

		for await _ in parser.parseEvents() {}

		#expect(parser.error == nil)
	}
}
