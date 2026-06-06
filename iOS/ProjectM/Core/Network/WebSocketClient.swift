import Foundation
import ProjectMShared

final class WebSocketClient: ObservableObject {
    private var task: URLSessionWebSocketTask?
    private let wsBase = ProcessInfo.processInfo.environment["WS_BASE_URL"] ?? "ws://localhost:8080/ws"

    var onEvent: ((WSEvent) -> Void)?

    func connect(token: String) {
        guard let url = URL(string: "\(wsBase)?token=\(token)") else { return }
        task = URLSession.shared.webSocketTask(with: url)
        task?.resume()
        receive()
    }

    func disconnect() {
        task?.cancel(with: .goingAway, reason: nil)
        task = nil
    }

    func send<T: Encodable>(_ eventType: WSEventType, payload: T) {
        guard let data = try? JSONEncoder().encode(payload),
              let eventData = try? JSONEncoder().encode(WSEvent(type: eventType, payload: data)),
              let str = String(data: eventData, encoding: .utf8) else { return }
        task?.send(.string(str)) { _ in }
    }

    private func receive() {
        task?.receive { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(.string(let text)):
                if let data = text.data(using: .utf8),
                   let event = try? JSONDecoder().decode(WSEvent.self, from: data) {
                    DispatchQueue.main.async { self.onEvent?(event) }
                }
                self.receive()
            case .success:
                self.receive()
            case .failure:
                DispatchQueue.global().asyncAfter(deadline: .now() + 3) { self.receive() }
            }
        }
    }
}
