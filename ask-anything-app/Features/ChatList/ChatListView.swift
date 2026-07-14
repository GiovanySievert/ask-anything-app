import SwiftUI

struct ChatListView: View {
  let chats: [ChatList]

  var body: some View {
    List(chats) { chat in
      ChatListRowView(chat: chat)
    }
    .presentationDetents([.medium, .large])
    .presentationDragIndicator(.visible)
  }
}
