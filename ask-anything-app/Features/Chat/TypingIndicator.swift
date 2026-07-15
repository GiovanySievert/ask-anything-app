import SwiftUI

struct TypingIndicator: View {
  @State private var animating = false

  private let dotCount = 3
  private let dotSize: CGFloat = 7

  var body: some View {
    HStack(spacing: 5) {
      ForEach(0..<dotCount, id: \.self) { index in
        Circle()
          .fill(AppColors.assistantBubbleText)
          .frame(width: dotSize, height: dotSize)
          .opacity(animating ? 1 : 0.3)
          .scaleEffect(animating ? 1 : 0.7)
          .animation(
            .easeInOut(duration: 0.6)
              .repeatForever()
              .delay(Double(index) * 0.2),
            value: animating
          )
      }
    }
    .onAppear {
      animating = true
    }
  }
}

#Preview {
  TypingIndicator()
    .padding()
    .background(AppColors.background)
}
