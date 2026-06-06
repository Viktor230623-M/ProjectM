import SwiftUI
import ProjectMShared

struct ConversationListView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var vm: ChatViewModel

    init() {
        _vm = StateObject(wrappedValue: ChatViewModel(api: APIClient(), ws: WebSocketClient()))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.mBackground.ignoresSafeArea()

                if vm.conversations.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 48))
                            .foregroundStyle(Color.mTextSecondary)
                        Text("No conversations yet")
                            .font(.display(22))
                            .foregroundStyle(Color.mTextPrimary)
                        Text("Start a conversation with a friend")
                            .font(.mCallout())
                            .foregroundStyle(Color.mTextSecondary)
                    }
                } else {
                    List(vm.conversations) { conv in
                        NavigationLink {
                            ChatView(conversation: conv, vm: vm)
                        } label: {
                            ConversationRowView(conversation: conv, currentUserId: appState.currentUser?.id)
                        }
                        .listRowBackground(Color.mBackground)
                        .listRowSeparatorTint(Color.mBorder)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .task { await vm.loadConversations() }
    }
}

private struct ConversationRowView: View {
    let conversation: ConversationDTO
    let currentUserId: UUID?

    private var otherMember: UserDTO? {
        conversation.members.first { $0.id != currentUserId }
    }

    private var title: String {
        conversation.name ?? otherMember?.displayName ?? "Chat"
    }

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.mSurface2)
                .frame(width: 52, height: 52)
                .overlay(
                    Text(title.prefix(1).uppercased())
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color.mTextPrimary)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.mTextPrimary)

                if let last = conversation.lastMessage {
                    Text(last.content)
                        .font(.mCallout())
                        .foregroundStyle(Color.mTextSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            if let last = conversation.lastMessage {
                Text(last.createdAt.formatted(.relative(presentation: .named)))
                    .font(.mCaption())
                    .foregroundStyle(Color.mTextSecondary)
            }
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }
}
