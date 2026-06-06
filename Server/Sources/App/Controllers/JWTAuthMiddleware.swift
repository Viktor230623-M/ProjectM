import JWT
import Vapor

struct UserJWTPayload: JWTPayload {
    var subject: SubjectClaim
    var expiration: ExpirationClaim
    var userId: UUID

    func verify(using algorithm: some JWTAlgorithm) async throws {
        try expiration.verifyNotExpired()
    }
}

struct JWTAuthMiddleware: AsyncMiddleware {
    func respond(to req: Request, chainingTo next: AsyncResponder) async throws -> Response {
        let payload = try await req.jwt.verify(as: UserJWTPayload.self)
        req.storage[UserIDKey.self] = payload.userId
        return try await next.respond(to: req)
    }
}

struct UserIDKey: StorageKey {
    typealias Value = UUID
}

extension Request {
    var userId: UUID {
        get throws {
            guard let id = storage[UserIDKey.self] else {
                throw Abort(.unauthorized)
            }
            return id
        }
    }
}
