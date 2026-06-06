import Vapor

func routes(_ app: Application) throws {
    let api = app.grouped("api", "v1")

    try api.register(collection: AuthController())

    let protected = api.grouped(JWTAuthMiddleware())
    try protected.register(collection: ChatController())
    try protected.register(collection: FeedController())
    try protected.register(collection: GraphController())
    try protected.register(collection: MediaController())

    // WebSocket
    app.webSocket("ws") { req, ws in
        await ChatWebSocketHandler.handle(req: req, ws: ws)
    }
}
