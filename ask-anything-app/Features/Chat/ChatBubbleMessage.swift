import SwiftUI

struct ChatBubbleMessage: View {
  let message: ChatMessage

  var body: some View {
    HStack {
      if message.isFromUser {
        Spacer(minLength: 48)
      }

      Text(message.text)
        .font(AppTypography.body)
        .foregroundStyle(
          message.isFromUser ? AppColors.userBubbleText : AppColors.assistantBubbleText
        )
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(message.isFromUser ? AppColors.userBubble : AppColors.assistantBubble)
        .clipShape(RoundedRectangle(cornerRadius: 16))

      if !message.isFromUser {
        Spacer(minLength: 48)
      }
    }
  }
}

#Preview {
  VStack(spacing: 12) {
    ForEach(ChatMessage.samples) { message in
      ChatBubbleMessage(message: message)
    }
  }
  .padding()
  .background(AppColors.background)
}
