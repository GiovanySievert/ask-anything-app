import SwiftUI

struct MessageRow: View {
  let message: ChatMessage
  let isVisible: Bool
  let onAppear: () -> Void

  var body: some View {
    ChatBubbleMessage(message: message)
      .frame(maxWidth: .infinity, alignment: .trailing)
      .opacity(isVisible ? 1 : 0)
      .offset(y: isVisible ? 0 : 40)
      .onAppear(perform: onAppear)
  }
}

struct ChatBubbleMessage: View {
  let message: ChatMessage

  private var isAwaitingReply: Bool {
    !message.isFromUser && message.text.isEmpty
  }

  var body: some View {
    HStack {
      if message.isFromUser {
        Spacer(minLength: 48)
      }

      ZStack {
        if isAwaitingReply {
          TypingIndicator()
            .transition(.scale(scale: 0.6).combined(with: .opacity))
        } else if message.isFromUser {
          Text(message.text)
            .font(AppTypography.body)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .foregroundStyle(AppColors.userBubbleText)
            .transition(.scale(scale: 0.6, anchor: .leading).combined(with: .opacity))
        } else {
          MarkdownText(text: message.text, color: AppColors.assistantBubbleText)
            .font(AppTypography.body)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .transition(.scale(scale: 0.6, anchor: .leading).combined(with: .opacity))
        }
      }
      .padding(.horizontal, 14)
      .padding(.vertical, 10)
      .background(message.isFromUser ? AppColors.userBubble : AppColors.assistantBubble)
      .clipShape(RoundedRectangle(cornerRadius: 16))
      .animation(.spring(duration: 0.35), value: isAwaitingReply)

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
