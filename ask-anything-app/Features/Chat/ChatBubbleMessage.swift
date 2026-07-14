import SwiftUI

struct ChatBubbleMessage: View {
  let message: ChatMessage

  var body: some View {
    HStack {
      if message.isFromUser {
        Spacer(minLength: 48)
      }

      Text(message.text)
        .font(.body)
        .foregroundStyle(message.isFromUser ? .black : .white)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(message.isFromUser ? .white : .white.opacity(0.14))
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
  .background(.black)
}
