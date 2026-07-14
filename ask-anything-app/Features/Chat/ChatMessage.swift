import Foundation

struct ChatMessage: Identifiable, Equatable {
    let id: UUID
    let text: String
    let isFromUser: Bool
    let createdAt: Date

    init(id: UUID = UUID(), text: String, isFromUser: Bool, createdAt: Date = .now) {
        self.id = id
        self.text = text
        self.isFromUser = isFromUser
        self.createdAt = createdAt
    }

    static let samples = [
        ChatMessage(text: "Oi! Como posso ajudar?", isFromUser: false),
        ChatMessage(text: "Me explica SwiftUI de forma simples.", isFromUser: true)
    ]
}
