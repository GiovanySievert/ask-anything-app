import SwiftUI

struct MarkdownText: View {
  let text: String
  let color: Color

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
        blockView(block)
      }
    }
  }

  private var blocks: [MarkdownBlock] {
    MarkdownBlock.parse(text)
  }

  @ViewBuilder
  private func blockView(_ block: MarkdownBlock) -> some View {
    switch block {
    case let .heading(level, content):
      inlineText(content)
        .font(headingFont(for: level))
        .foregroundStyle(color)

    case let .listItem(content):
      HStack(alignment: .top, spacing: 8) {
        Text("•")
          .foregroundStyle(color)
        inlineText(content)
          .foregroundStyle(color)
          .frame(maxWidth: .infinity, alignment: .leading)
      }

    case let .paragraph(content):
      inlineText(content)
        .foregroundStyle(color)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
  }

  private func inlineText(_ content: String) -> Text {
    let options = AttributedString.MarkdownParsingOptions(
      interpretedSyntax: .inlineOnlyPreservingWhitespace
    )
    if let attributed = try? AttributedString(markdown: content, options: options) {
      return Text(attributed)
    }
    return Text(content)
  }

  private func headingFont(for level: Int) -> Font {
    switch level {
    case 1: return .system(size: 22, weight: .bold)
    case 2: return .system(size: 19, weight: .bold)
    default: return .system(size: 17, weight: .semibold)
    }
  }
}

enum MarkdownBlock {
  case heading(level: Int, content: String)
  case listItem(content: String)
  case paragraph(content: String)

  static func parse(_ text: String) -> [MarkdownBlock] {
    text
      .components(separatedBy: "\n")
      .compactMap { line in
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }

        if let heading = parseHeading(trimmed) {
          return heading
        }
        if let item = parseListItem(trimmed) {
          return item
        }
        return .paragraph(content: trimmed)
      }
  }

  private static func parseHeading(_ line: String) -> MarkdownBlock? {
    var level = 0
    var index = line.startIndex
    while index < line.endIndex, line[index] == "#" {
      level += 1
      index = line.index(after: index)
    }
    guard level > 0, level <= 6, index < line.endIndex, line[index] == " " else {
      return nil
    }
    let content = String(line[index...]).trimmingCharacters(in: .whitespaces)
    return .heading(level: level, content: content)
  }

  private static func parseListItem(_ line: String) -> MarkdownBlock? {
    for marker in ["- ", "* "] where line.hasPrefix(marker) {
      let content = String(line.dropFirst(marker.count)).trimmingCharacters(in: .whitespaces)
      return .listItem(content: content)
    }
    return nil
  }
}
