import SwiftUI

struct ChatView: View {
  @State private var viewModel: ChatViewModel
  @State private var animatedMessageIDs: Set<UUID>
  @State private var isShowingChatList = false
  @FocusState private var isInputFocused: Bool

  @MainActor
  init(viewModel: ChatViewModel? = nil) {
    let viewModel = viewModel ?? ChatViewModel()
    _viewModel = State(initialValue: viewModel)
    _animatedMessageIDs = State(initialValue: Set(viewModel.messages.map(\.id)))
  }

  var body: some View {
    @Bindable var viewModel = viewModel

    ZStack {
      Color.black
        .ignoresSafeArea()

      VStack(spacing: 0) {
        HStack {
          Spacer()
          Button {
            withAnimation(.spring(duration: 0.25)) {
              isShowingChatList.toggle()
            }
          } label: {
            Image(systemName: "chevron.down")
              .font(.system(size: 24, weight: .medium))
              .foregroundStyle(.white)
              .rotationEffect(.degrees(isShowingChatList ? 180 : 0))
          }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)

        ZStack {
          if viewModel.isShowingEmptyState {
            VStack(spacing: 12) {
              Text("Ask Anything")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.white)

              Text("Simulate an interview with a real-life interviewer")
                .font(.body)
                .foregroundStyle(.white.opacity(0.62))
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 28)
          }

          GeometryReader { geometry in
            ScrollViewReader { proxy in
              ScrollView {
                VStack(spacing: 12) {
                  ForEach(viewModel.messages) { chatMessage in
                    ChatBubbleMessage(message: chatMessage)
                      .frame(maxWidth: .infinity, alignment: .trailing)
                      .id(chatMessage.id)
                      .offset(
                        y: animatedMessageIDs.contains(chatMessage.id) ? 0 : geometry.size.height
                      )
                  }

                  Color.clear
                    .id("messagesBottom")
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
              }
							.scrollIndicators(.hidden)
              .scrollDismissesKeyboard(.interactively)
              .onChange(of: viewModel.messages.count) { _, _ in
                scrollToMessagesBottom(with: proxy)
              }
              .onChange(of: animatedMessageIDs.count) { _, _ in
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
				.safeAreaInset(edge: .bottom) {
					ChatInputBar(message: $viewModel.message, onSend: sendMessage, isFocused: $isInputFocused)
						.padding(.bottom, 18)
				}
      }
      .sheet(isPresented: $isShowingChatList) {
        ChatListView(chats: ChatList.samples)
      }
    }
  }

  private func scrollToMessagesBottom(with proxy: ScrollViewProxy) {
    DispatchQueue.main.async {
      withAnimation(.spring(duration: 0.3)) {
        proxy.scrollTo("messagesBottom", anchor: .bottom)
      }
    }
  }

  private func animateMessage(_ message: ChatMessage) {
    DispatchQueue.main.async {
      withAnimation(.spring(duration: 0.4)) {
        animatedMessageIDs = animatedMessageIDs.union([message.id])
      }
    }
  }

  private func sendMessage() {
    guard let sentMessage = viewModel.sendMessage() else { return }
    animateMessage(sentMessage)
  }
}

#Preview {
  ChatView(viewModel: ChatViewModel(messages: ChatMessage.samples))
}
