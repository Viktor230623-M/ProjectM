import JWT
import Vapor

struct AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let auth = routes.grouped("auth")
        auth.post("request-otp", use: requestOTP)
        auth.post("verify-otp", use: verifyOTP)
        auth.post("refresh", use: refreshToken)
    }

    // MARK: - Request OTP

    struct OTPRequest: Content {
        let phoneNumber: String
    }

    struct OTPResponse: Content {
        let message: String
        let otp: String? // dev mode only
    }

    func requestOTP(req: Request) async throws -> OTPResponse {
        let body = try req.content.decode(OTPRequest.self)
        let phone = body.phoneNumber.trimmingCharacters(in: .whitespaces)

        let code = String(format: "%06d", Int.random(in: 0...999999))
        let hash = try Bcrypt.hash(code)

        // Invalidate old codes
        try await OTPCode.query(on: req.db)
            .filter(\.$phoneNumber == phone)
            .filter(\.$used == false)
            .all()
            .asyncForEach { $0.used = true; try await $0.save(on: req.db) }

        let otp = OTPCode(phoneNumber: phone, codeHash: hash, expiresAt: Date().addingTimeInterval(600))
        try await otp.save(on: req.db)

        let isDev = req.application.environment == .development
        return OTPResponse(message: "OTP sent", otp: isDev ? code : nil)
    }

    // MARK: - Verify OTP

    struct OTPVerifyRequest: Content {
        let phoneNumber: String
        let code: String
        let username: String?
    }

    struct TokenResponse: Content {
        let accessToken: String
        let refreshToken: String
        let user: UserResponse
    }

    struct UserResponse: Content {
        let id: UUID
        let username: String
        let displayName: String
    }

    func verifyOTP(req: Request) async throws -> TokenResponse {
        let body = try req.content.decode(OTPVerifyRequest.self)
        let phone = body.phoneNumber.trimmingCharacters(in: .whitespaces)

        guard let otpRecord = try await OTPCode.query(on: req.db)
            .filter(\.$phoneNumber == phone)
            .filter(\.$used == false)
            .sort(\.$expiresAt, .descending)
            .first()
        else {
            throw Abort(.badRequest, reason: "No active OTP found")
        }

        guard !otpRecord.isExpired, try Bcrypt.verify(body.code, created: otpRecord.codeHash) else {
            throw Abort(.badRequest, reason: "Invalid or expired OTP")
        }

        otpRecord.used = true
        try await otpRecord.save(on: req.db)

        // Upsert user
        let user: User
        if let existing = try await User.query(on: req.db).filter(\.$phoneNumber == phone).first() {
            user = existing
        } else {
            let username = body.username ?? "user_\(Int.random(in: 10000...99999))"
            user = User(phoneNumber: phone, username: username, displayName: username)
            try await user.save(on: req.db)
        }

        return try TokenResponse(
            accessToken: try makeAccessToken(userId: user.requireID(), req: req),
            refreshToken: try makeRefreshToken(userId: user.requireID(), req: req),
            user: UserResponse(id: user.requireID(), username: user.username, displayName: user.displayName)
        )
    }

    // MARK: - Refresh

    struct RefreshRequest: Content {
        let refreshToken: String
    }

    func refreshToken(req: Request) async throws -> TokenResponse {
        let body = try req.content.decode(RefreshRequest.self)
        let payload = try await req.jwt.verify(body.refreshToken, as: UserJWTPayload.self)

        guard let user = try await User.find(payload.userId, on: req.db) else {
            throw Abort(.unauthorized)
        }

        return try TokenResponse(
            accessToken: try makeAccessToken(userId: user.requireID(), req: req),
            refreshToken: try makeRefreshToken(userId: user.requireID(), req: req),
            user: UserResponse(id: user.requireID(), username: user.username, displayName: user.displayName)
        )
    }

    // MARK: - Helpers

    private func makeAccessToken(userId: UUID, req: Request) throws -> String {
        let payload = UserJWTPayload(
            subject: .init(value: userId.uuidString),
            expiration: .init(value: Date().addingTimeInterval(900)),
            userId: userId
        )
        return try req.jwt.sign(payload)
    }

    private func makeRefreshToken(userId: UUID, req: Request) throws -> String {
        let payload = UserJWTPayload(
            subject: .init(value: userId.uuidString),
            expiration: .init(value: Date().addingTimeInterval(2592000)),
            userId: userId
        )
        return try req.jwt.sign(payload)
    }
}
