import Foundation

struct ChatList: Identifiable, Equatable {
    let id: UUID
    let title: String
    let updatedAt: Date
    let messages: [ChatMessage]

    init(id: UUID = UUID(), title: String, updatedAt: Date = .now, messages: [ChatMessage] = []) {
        self.id = id
        self.title = title
        self.updatedAt = updatedAt
        self.messages = messages
    }

    static let samples = [
        ChatList(title: "Primeiro chat", messages: ChatMessage.samples)
    ]
}
