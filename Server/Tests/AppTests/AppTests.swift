import XCTVapor
@testable import App

final class AppTests: XCTestCase {
    func testHealthCheck() async throws {
        let app = try await Application.make(.testing)
        defer { app.shutdown() }
        try await configure(app)
        try await app.test(.GET, "/") { res in
            // Basic smoke test — server starts without crashing
            XCTAssertNotNil(res)
        }
    }
}
