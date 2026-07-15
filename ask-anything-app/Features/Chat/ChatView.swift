import SwiftUI

struct ChatView: View {
  @State private var viewModel: ChatViewModel
  @State private var animatedMessageIDs: Set<UUID>
  @State private var isShowingChatList = false
  @FocusState private var isInputFocused: Bool

  @MainActor
  init(viewModel: ChatViewModel? = nil) {
    let viewModel: ChatViewModel = viewModel ?? ChatViewModel()
    _viewModel = State(initialValue: viewModel)
    _animatedMessageIDs = State(initialValue: Set(viewModel.messages.map(\.id)))
  }

  var body: some View {
    @Bindable var viewModel: ChatViewModel = viewModel

    ZStack {
      AppColors.background
        .ignoresSafeArea()
      VStack(spacing: 0) {
        ZStack {
          if viewModel.isShowingEmptyState {
            ChatEmptyState()
          }

          GeometryReader { geometry in
            ScrollViewReader { proxy in
              ScrollView {
                VStack(spacing: 12) {
                  ForEach(viewModel.messages) { chatMessage in
                    MessageRow(
                      message: chatMessage,
                      isVisible: animatedMessageIDs.contains(chatMessage.id)
                    ) {
                      withAnimation(.spring(duration: 0.4)) {
                        _ = animatedMessageIDs.insert(chatMessage.id)
                      }
                    }
                    .id(chatMessage.id)
                  }

                  Color.clear
                    .id("messagesBottom")
                }
                .padding(.horizontal, AppSpacing.medium)
                .padding(.top, AppSpacing.large)
              }
              .scrollIndicators(.hidden)
              .scrollDismissesKeyboard(.interactively)
              .onChange(of: viewModel.messages.count) { _, _ in
                scrollToMessagesBottom(with: proxy)
              }
              .onChange(of: isInputFocused) { _, isFocused in
                if isFocused {
                  scrollToMessagesBottom(with: proxy)
                }
              }
            }
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
          isInputFocused = false
        }
        .safeAreaInset(edge: .top) {
          HStack {
            Spacer()
            chatListToggleButton
          }
          .padding(.horizontal, 20)
          .padding(.top, 12)
        }
        .safeAreaInset(edge: .bottom) {
          ChatInputBar(message: $viewModel.message, onSend: sendMessage, isFocused: $isInputFocused)
        }
      }
      .sheet(isPresented: $isShowingChatList) {
        ChatListView(chats: ChatList.samples)
      }
    }
  }

  private var chatListToggleButton: some View {
    Button {
      withAnimation(.spring(duration: 0.25)) {
        isShowingChatList.toggle()
      }
    } label: {
      Image(systemName: "chevron.down")
        .font(.system(size: 24, weight: .medium))
        .foregroundStyle(AppColors.primaryText)
        .rotationEffect(.degrees(isShowingChatList ? 180 : 0))
        .frame(width: 52, height: 44)
        .appGlass(
          in: Circle(),
          tint: AppColors.glassOverlayTint,
          isInteractive: true
        )
    }
  }

  private func scrollToMessagesBottom(with proxy: ScrollViewProxy, animated: Bool = true) {
    if animated {
      withAnimation(.easeOut(duration: 0.15)) {
        proxy.scrollTo("messagesBottom", anchor: .bottom)
      }
    } else {
      proxy.scrollTo("messagesBottom", anchor: .bottom)
    }
  }

  private func sendMessage() {
    isInputFocused = false
    Task {
      await viewModel.sendMessage()
    }
  }
}

#Preview {
  ChatView(viewModel: ChatViewModel(messages: ChatMessage.samples))
}
