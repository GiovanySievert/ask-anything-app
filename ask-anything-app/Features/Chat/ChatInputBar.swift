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
        .font(AppTypography.body)
        .foregroundStyle(AppColors.primaryText)
        .focused($isFocused)
        .onSubmit(onSend)
        .padding(.horizontal, AppSpacing.medium)
        .frame(height: 52)
        .appGlass(in: RoundedRectangle(cornerRadius: 16))
        .contentShape(RoundedRectangle(cornerRadius: 16))
        .onTapGesture { isFocused = true }

      Button {
        onSend()
      } label: {
        Image(systemName: "arrow.up")
          .font(.system(size: 17, weight: .bold))
          .foregroundStyle(AppColors.background)
          .frame(width: 52, height: 44)
          .appGlass(
            in: Circle(),
            tint: message.isEmpty ? AppColors.sendButtonIdle : AppColors.sendButtonActive,
            isInteractive: true
          )
      }
      .disabled(message.isEmpty)
      .animation(.spring(duration: 0.25), value: message.isEmpty)
    }
    .padding(.horizontal, isFocused ? AppSpacing.small : AppSpacing.large)
    .padding(.bottom, isFocused ? AppSpacing.medium : 0)
    .animation(.spring(duration: 0.30), value: isFocused)
  }
}

#Preview {
  @Previewable @State var message = ""
  @Previewable @FocusState var isFocused: Bool

  ChatInputBar(message: $message, onSend: {}, isFocused: $isFocused)
    .padding()
    .background(AppColors.background)
}
