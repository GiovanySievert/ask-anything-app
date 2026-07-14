import SwiftUI

struct ChatListView: View {
  let chats: [ChatList]

  var body: some View {
    List(chats) { chat in
      ChatListRowView(chat: chat)
    }
    .presentationDetents([.medium, .large])
    .presentationDragIndicator(.visible)

    HStack {
      Spacer()
      Button {
      } label: {
        Image(systemName: "plus")
          .font(.system(size: 17, weight: .bold))
          .foregroundStyle(AppColors.background)
          .frame(width: 52, height: 44)
          .appGlass(
            in: Circle(),
            tint: AppColors.sendButtonIdle,
            isInteractive: true
          )
          .padding(.horizontal, AppSpacing.medium)
      }
    }

  }
}
