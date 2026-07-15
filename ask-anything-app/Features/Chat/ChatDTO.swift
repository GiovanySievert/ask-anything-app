import Foundation

struct CreateConversationRequest: Encodable {
  let title: String?
}

struct CreateConversationResponse: Decodable {
  let id: String
}

struct SendMessageRequest: Encodable {
  let content: String
}
