import SwiftUI

struct ChatListRowView: View {
    let chat: ChatList

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(chat.title)
                .font(.headline)
                .foregroundStyle(.primary)

            Text(chat.messages.last?.text ?? "Nenhuma mensagem ainda")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    List(ChatList.samples) { chat in
        ChatListRowView(chat: chat)
    }
}
