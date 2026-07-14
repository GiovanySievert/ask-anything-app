import SwiftUI

struct ChatInputBar: View {
  @Binding var message: String
  let onSend: () -> Void

  @FocusState.Binding var isFocused: Bool

  var body: some View {
    HStack(spacing: 12) {
      TextField("Ask anything", text: $message)
        .textInputAutocapitalization(.sentences)
        .autocorrectionDisabled()
        .textContentType(.none)
        .submitLabel(.send)
        .foregroundStyle(.white)
        .focused($isFocused)
        .onSubmit(onSend)
        .padding(.horizontal, 16)
        .frame(height: 52)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))
        .overlay {
          RoundedRectangle(cornerRadius: 16)
            .stroke(.black.opacity(0.18), lineWidth: 1)
            .allowsHitTesting(false)
        }
        .contentShape(RoundedRectangle(cornerRadius: 16))
        .onTapGesture { isFocused = true }

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
  @Previewable @FocusState var isFocused: Bool

  ChatInputBar(message: $message, onSend: {}, isFocused: $isFocused)
    .padding()
    .background(.black)
}
