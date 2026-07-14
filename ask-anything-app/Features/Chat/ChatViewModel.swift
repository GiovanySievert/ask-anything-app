import Foundation
import Observation

@MainActor
@Observable
final class ChatViewModel {
  var message = ""
  var messages: [ChatMessage] = []
  var isShowingEmptyState = true

  func sendMessage() -> ChatMessage? {
    guard let text = normalizedMessageText() else { return nil }

    let sentMessage = makeUserMessage(text)
    clearInput()
    appendMessage(sentMessage)

    return sentMessage
  }

  private func normalizedMessageText() -> String? {
    let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmedMessage.isEmpty ? nil : trimmedMessage
  }

  private func makeUserMessage(_ text: String) -> ChatMessage {
    ChatMessage(text: text, isFromUser: true)
  }

  private func clearInput() {
    message = ""
  }

  private func appendMessage(_ message: ChatMessage) {
    isShowingEmptyState = false
    messages.append(message)
  }
}
