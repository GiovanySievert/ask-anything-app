import Foundation
import Observation

@MainActor
@Observable
final class ChatViewModel {
  var message = ""
  var messages: [ChatMessage] = []
  var isShowingEmptyState = true

  private let apiClient: APIClientProtocol
  private let streamingClient: StreamingAPIClientProtocol
  private var conversationId: String?

  @ObservationIgnored private var pendingText = ""
  @ObservationIgnored private var streamFinished = false

  init(
    apiClient: APIClientProtocol = APIClient(baseURL: ChatViewModel.baseURL),
    streamingClient: StreamingAPIClientProtocol = StreamingAPIClient(baseURL: ChatViewModel.baseURL)
  ) {
    self.apiClient = apiClient
    self.streamingClient = streamingClient
  }

  init(
    messages: [ChatMessage],
    apiClient: APIClientProtocol = APIClient(baseURL: ChatViewModel.baseURL),
    streamingClient: StreamingAPIClientProtocol = StreamingAPIClient(baseURL: ChatViewModel.baseURL)
  ) {
    self.messages = messages
    self.isShowingEmptyState = messages.isEmpty
    self.apiClient = apiClient
    self.streamingClient = streamingClient
  }

  @discardableResult
  func sendMessage() async -> ChatMessage? {
    guard let text = normalizedMessageText() else { return nil }

    let sentMessage = makeUserMessage(text)
    clearInput()
    appendMessage(sentMessage)

    let reply = ChatMessage(text: "", isFromUser: false)
    appendMessage(reply)

    do {
      let conversationId = try await resolveConversationId()
      let stream = streamingClient.stream(
        "api/v1/conversations/\(conversationId)/messages",
        body: SendMessageRequest(content: text)
      )

      pendingText = ""
      streamFinished = false
      let typing = startTypewriter(for: reply.id)

      for try await delta in stream {
        pendingText += delta
      }
      streamFinished = true
      await typing.value
    } catch {
      removeEmptyReply(reply.id)
    }

    return sentMessage
  }

  private func startTypewriter(for id: UUID) -> Task<Void, Never> {
    Task { @MainActor in
      let tick = Duration.milliseconds(33)
      let charactersPerTick = 6

      while !Task.isCancelled {
        if pendingText.isEmpty {
          if streamFinished { break }
          try? await Task.sleep(for: tick)
          continue
        }
        let count = min(charactersPerTick, pendingText.count)
        let chunk = String(pendingText.prefix(count))
        pendingText.removeFirst(count)
        appendText(chunk, toMessageWith: id)
        try? await Task.sleep(for: tick)
      }
    }
  }

  private func resolveConversationId() async throws -> String {
    if let conversationId { return conversationId }
    let response: CreateConversationResponse = try await apiClient.post(
      "api/v1/conversations",
      body: CreateConversationRequest(title: nil)
    )
    conversationId = response.id
    return response.id
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

  private func appendText(_ text: String, toMessageWith id: UUID) {
    guard let index = messages.lastIndex(where: { $0.id == id }) else { return }
    let current = messages[index]
    messages[index] = ChatMessage(
      id: current.id,
      text: current.text + text,
      isFromUser: current.isFromUser,
      createdAt: current.createdAt
    )
  }

  private func removeEmptyReply(_ id: UUID) {
    guard let index = messages.firstIndex(where: { $0.id == id }) else { return }
    if messages[index].text.isEmpty {
      messages.remove(at: index)
    }
  }

  nonisolated private static let baseURL = URL(string: "http://localhost:8080")!
}
