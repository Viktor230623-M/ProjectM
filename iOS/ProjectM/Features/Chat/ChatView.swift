import SwiftUI
import ProjectMShared

struct ChatView: View {
    let conversation: ConversationDTO
    @ObservedObject var vm: ChatViewModel
    @EnvironmentObject var appState: AppState
    @State private var inputText = ""
    @State private var scrollProxy: ScrollViewProxy?

    private var title: String {
        conversation.name ?? conversation.members.first { $0.id != appState.currentUser?.id }?.displayName ?? "Chat"
    }

    var body: some View {
        ZStack {
            Color.mBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 4) {
                            ForEach(vm.messages) { msg in
                                MessageBubbleView(
                                    message: msg,
                                    isOwn: msg.senderId == appState.currentUser?.id
                                )
                                .id(msg.id)
                            }

                            if !vm.typingUserIds.isEmpty {
                                TypingIndicatorView()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 16)
                            }
                        }
                        .padding(.vertical, 12)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .onChange(of: vm.messages.count) { _, _ in
                        if let last = vm.messages.last {
                            withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                        }
                    }
                }

                Divider().background(Color.mBorder)
                ChatInputBar(text: $inputText) {
                    guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    let text = inputText
                    inputText = ""
                    Task { await vm.sendMessage(conversationId: conversation.id, text: text) }
                } onTyping: {
                    guard let userId = appState.currentUser?.id else { return }
                    vm.sendTyping(conversationId: conversation.id, userId: userId)
                }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task { await vm.loadMessages(conversationId: conversation.id) }
    }
}

private struct ChatInputBar: View {
    @Binding var text: String
    let onSend: () -> Void
    let onTyping: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            TextField("Message", text: $text, axis: .vertical)
                .font(.mBody())
                .foregroundStyle(Color.mTextPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.mSurface2)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .lineLimit(1...5)
                .tint(.mPrimary)
                .onChange(of: text) { _, _ in onTyping() }

            Button(action: onSend) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(text.trimmingCharacters(in: .whitespaces).isEmpty ? Color.mSurface2 : Color.mPrimary)
                    .clipShape(Circle())
                    .animation(.easeInOut(duration: 0.15), value: text.isEmpty)
            }
            .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
            .accessibilityLabel("Send message")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.mBackground)
    }
}
