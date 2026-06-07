import Foundation

enum Endpoint {
    static let base = ProcessInfo.processInfo.environment["API_BASE_URL"] ?? "http://31.97.180.253/api/v1"

    case requestOTP
    case verifyOTP
    case refreshToken
    case conversations
    case messages(conversationId: String)
    case sendMessage(conversationId: String)
    case createConversation
    case feed
    case createPost
    case deletePost(postId: String)
    case graph
    case uploadMedia

    var path: String {
        switch self {
        case .requestOTP: return "/auth/request-otp"
        case .verifyOTP: return "/auth/verify-otp"
        case .refreshToken: return "/auth/refresh"
        case .conversations: return "/chat/conversations"
        case .messages(let id): return "/chat/conversations/\(id)/messages"
        case .sendMessage(let id): return "/chat/conversations/\(id)/messages"
        case .createConversation: return "/chat/conversations"
        case .feed: return "/feed"
        case .createPost: return "/feed"
        case .deletePost(let id): return "/feed/\(id)"
        case .graph: return "/graph"
        case .uploadMedia: return "/media/upload"
        }
    }

    var url: URL { URL(string: Self.base + path)! }
}
