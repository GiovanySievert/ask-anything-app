import SwiftUI

struct ChatListView: View {
    private let viewModel = ChatListViewModel()

    var body: some View {
        NavigationStack {
            List(viewModel.chats) { chat in
                ChatListRowView(chat: chat)
            }
            .navigationTitle("Chats")
        }
    }
}

#Preview {
    ChatListView()
}
