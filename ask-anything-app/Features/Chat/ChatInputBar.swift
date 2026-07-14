import SwiftUI

struct ChatInputBar: View {
  @Binding var message: String
  let onSend: () -> Void

  var body: some View {
    HStack(spacing: 12) {
      ZStack {
        RoundedRectangle(cornerRadius: 16)
          .glassEffect(
            .regular,
            in: RoundedRectangle(cornerRadius: 16)
          )
          .overlay {
            RoundedRectangle(cornerRadius: 16)
              .stroke(.black.opacity(0.18), lineWidth: 1)
          }
          .allowsHitTesting(false)

        TextField("Ask anything", text: $message)
          .textInputAutocapitalization(.sentences)
          .autocorrectionDisabled()
          .submitLabel(.send)
          .foregroundStyle(.white)
          .padding(.horizontal, 16)
          .onSubmit(onSend)
      }
      .frame(height: 52)
      .clipShape(RoundedRectangle(cornerRadius: 16))

      Button {
        onSend()
      } label: {
        Image(systemName: "arrow.up")
          .font(.system(size: 17, weight: .bold))
          .foregroundStyle(.black)
          .frame(width: 52, height: 44)
          .glassEffect(
            .regular
              .tint(
                message.isEmpty
                  ? .white.opacity(0.35)
                  : .white
              )
              .interactive(),
            in: Circle()
          )
          .clipShape(Circle())
      }
      .disabled(message.isEmpty)
      .animation(.spring(duration: 0.25), value: message.isEmpty)
    }
    .background(.clear)
    .padding(.horizontal, 16)
  }
}

#Preview {
  @Previewable @State var message = ""

  ChatInputBar(message: $message, onSend: {})
    .padding()
    .background(.black)
}
