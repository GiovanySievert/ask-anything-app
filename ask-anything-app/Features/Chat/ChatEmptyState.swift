import SwiftUI

struct ChatEmptyState: View {
  var body: some View {
    VStack(spacing: 12) {
      Text("Ask Anything")
        .font(AppTypography.title)
        .foregroundStyle(AppColors.primaryText)

      Text("Simulate an interview with a real-life interviewer")
        .font(AppTypography.body)
        .foregroundStyle(AppColors.secondaryText)
    }
    .multilineTextAlignment(.center)
    .padding(.horizontal, AppSpacing.extraLarge)
  }
}

#Preview {
  ChatEmptyState()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(AppColors.background)
}
