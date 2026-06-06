import Vapor
import ProjectMShared

struct FeedController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let feed = routes.grouped("feed")
        feed.get(use: getFeed)
        feed.post(use: createPost)
        feed.delete(":postId", use: deletePost)
    }

    func getFeed(req: Request) async throws -> [PostDTO] {
        let userId = try req.userId

        let friendIds = try await friendIds(for: userId, db: req.db)
        var visibleIds = friendIds
        visibleIds.append(userId)

        let posts = try await Post.query(on: req.db)
            .filter(\.$authorId ~~ visibleIds)
            .filter(\.$deletedAt == nil)
            .sort(\.$createdAt, .descending)
            .range(..<50)
            .all()

        let authorIds = Array(Set(posts.map { $0.authorId }))
        let authors = try await User.query(on: req.db).filter(\.$id ~~ authorIds).all()
        let authorMap = try Dictionary(uniqueKeysWithValues: authors.map { try ($0.requireID(), $0) })

        return try posts.map { post in
            let author = authorMap[post.authorId]
            return try PostDTO(
                id: post.requireID(),
                authorId: post.authorId,
                author: author?.toDTO(),
                contentType: ContentType(rawValue: post.contentType) ?? .text,
                content: post.content,
                caption: post.caption,
                createdAt: post.createdAt ?? Date()
            )
        }
    }

    struct CreatePostRequest: Content {
        let contentType: String
        let content: String
        let caption: String?
    }

    func createPost(req: Request) async throws -> PostDTO {
        let userId = try req.userId
        let body = try req.content.decode(CreatePostRequest.self)
        let ct = ContentType(rawValue: body.contentType) ?? .text

        let post = Post(authorId: userId, contentType: ct, content: body.content, caption: body.caption)
        try await post.save(on: req.db)

        let user = try await User.find(userId, on: req.db)
        return try PostDTO(
            id: post.requireID(),
            authorId: userId,
            author: user?.toDTO(),
            contentType: ct,
            content: post.content,
            caption: post.caption,
            createdAt: post.createdAt ?? Date()
        )
    }

    func deletePost(req: Request) async throws -> HTTPStatus {
        guard let postId = req.parameters.get("postId", as: UUID.self) else { throw Abort(.badRequest) }
        let userId = try req.userId

        guard let post = try await Post.find(postId, on: req.db), post.authorId == userId else {
            throw Abort(.forbidden)
        }
        post.deletedAt = Date()
        try await post.save(on: req.db)
        return .noContent
    }

    private func friendIds(for userId: UUID, db: Database) async throws -> [UUID] {
        let friendships = try await Friendship.query(on: db)
            .group(.or) { g in
                g.filter(\.$userAId == userId)
                g.filter(\.$userBId == userId)
            }
            .filter(\.$status == "accepted")
            .all()

        return friendships.map { $0.userAId == userId ? $0.userBId : $0.userAId }
    }
}
