import Foundation
import ProjectMShared

@MainActor
final class WebSocketClient: ObservableObject {
    private var task: URLSessionWebSocketTask?
    private let wsBase = ProcessInfo.processInfo.environment["WS_BASE_URL"] ?? "ws://localhost:8080/ws"

    var onEvent: ((WSEvent) -> Void)?

    func connect(token: String) {
        guard let url = URL(string: "\(wsBase)?token=\(token)") else { return }
        task = URLSession.shared.webSocketTask(with: url)
        task?.resume()
        listen()
    }

    func disconnect() {
        task?.cancel(with: .goingAway, reason: nil)
        task = nil
    }

    func send<T: Encodable>(_ event: WSEventType, payload: T) {
        guard let data = try? JSONEncoder().encode(payload),
              let json = try? JSONEncoder().encode(WSEvent(type: event, payload: data)),
              let str = String(data: json, encoding: .utf8) else { return }
        task?.send(.string(str)) { _ in }
    }

    private func listen() {
        task?.receive { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(.string(let text)):
                if let data = text.data(using: .utf8),
                   let event = try? JSONDecoder().decode(WSEvent.self, from: data) {
                    Task { @MainActor in self.onEvent?(event) }
                }
                self.listen()
            case .success(.data):
                self.listen()
            case .failure:
                // Reconnect after delay
                Task {
                    try? await Task.sleep(nanoseconds: 3_000_000_000)
                    await MainActor.run { self.listen() }
                }
            @unknown default:
                break
            }
        }
    }
}
