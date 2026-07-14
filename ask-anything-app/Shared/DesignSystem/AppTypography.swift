import SwiftUI

enum AppTypography {
  static let title: Font = Font.custom("JetBrainsMono-Medium", size: 34, relativeTo: .largeTitle)
	static let title2: Font = Font.custom("JetBrainsMono-Medium", size: 18, relativeTo: .title)
  static let headline: Font = Font.custom("InterTight-SemiBold", size: 17, relativeTo: .headline)
  static let body: Font = Font.custom("InterTight-Regular", size: 17, relativeTo: .body)
  static let subheadline: Font = Font.custom(
    "InterTight-Regular", size: 15, relativeTo: .subheadline)
  static let caption: Font = Font.custom("InterTight-Regular", size: 12, relativeTo: .caption)
}
