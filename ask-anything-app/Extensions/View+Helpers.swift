import SwiftUI

extension View {
  func appGlass(
    in shape: some Shape,
    tint: Color? = nil,
    isInteractive: Bool = false
  ) -> some View {
    var glass: Glass = .regular
    if let tint {
      glass = glass.tint(tint)
    }
    if isInteractive {
      glass = glass.interactive()
    }

    return
      self
      .glassEffect(glass, in: shape)
      .overlay {
        shape
          .stroke(AppColors.glassBorder, lineWidth: 1)
          .allowsHitTesting(false)
      }
      .clipShape(shape)
  }
}
