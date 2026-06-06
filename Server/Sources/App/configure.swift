import Fluent
import FluentPostgresDriver
import JWT
import Vapor

public func configure(_ app: Application) async throws {
    // MARK: - Database
    let dbConfig = SQLPostgresConfiguration(
        hostname: Environment.get("DB_HOST") ?? "localhost",
        port: Int(Environment.get("DB_PORT") ?? "5432") ?? 5432,
        username: Environment.get("DB_USER") ?? "projectm",
        password: Environment.get("DB_PASSWORD") ?? "projectm",
        database: Environment.get("DB_NAME") ?? "projectm",
        tls: .disable
    )
    app.databases.use(.postgres(configuration: dbConfig), as: .psql)

    // MARK: - JWT
    let jwtSecret = Environment.get("JWT_SECRET") ?? "change-me-in-production"
    await app.jwt.keys.add(hmac: .init(stringLiteral: jwtSecret), digestAlgorithm: .sha256)

    // MARK: - Migrations
    app.migrations.add(CreateUsers())
    app.migrations.add(CreateOTPCodes())
    app.migrations.add(CreateConversations())
    app.migrations.add(CreateConversationMembers())
    app.migrations.add(CreateMessages())
    app.migrations.add(CreateFriendships())
    app.migrations.add(CreatePosts())
    app.migrations.add(CreateStories())
    try await app.autoMigrate()

    // MARK: - Middleware
    app.middleware.use(CORSMiddleware(configuration: .default()))
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // MARK: - Routes
    try routes(app)
}
