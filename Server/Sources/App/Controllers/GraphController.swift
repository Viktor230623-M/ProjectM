import Vapor
import ProjectMShared

struct GraphController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get("graph", use: getGraph)
    }

    func getGraph(req: Request) async throws -> GraphResponseDTO {
        let userId = try req.userId

        let allFriendships = try await Friendship.query(on: req.db)
            .filter(\.$status == "accepted")
            .all()

        // Direct friends of current user
        let directFriendIds = Set(allFriendships.compactMap { f -> UUID? in
            if f.userAId == userId { return f.userBId }
            if f.userBId == userId { return f.userAId }
            return nil
        })

        // Friends of friends
        var fofIds = Set<UUID>()
        for fId in directFriendIds {
            let fof = allFriendships.compactMap { f -> UUID? in
                if f.userAId == fId { return f.userBId }
                if f.userBId == fId { return f.userAId }
                return nil
            }
            fofIds.formUnion(fof)
        }
        fofIds.subtract(directFriendIds)
        fofIds.remove(userId)

        var visibleIds = directFriendIds
        visibleIds.insert(userId)
        visibleIds.formUnion(fofIds)

        let users = try await User.query(on: req.db)
            .filter(\.$id ~~ Array(visibleIds))
            .filter(\.$graphVisibility == true)
            .all()

        // Always include self
        let selfVisible = users.contains { (try? $0.requireID()) == userId }
        var finalUsers = users
        if !selfVisible, let self = try await User.find(userId, on: req.db) {
            finalUsers.append(self)
        }

        let visibleUserIds = Set(try finalUsers.map { try $0.requireID() })

        // Build connection count map
        var connectionCount: [UUID: Int] = [:]
        for f in allFriendships {
            if visibleUserIds.contains(f.userAId) { connectionCount[f.userAId, default: 0] += 1 }
            if visibleUserIds.contains(f.userBId) { connectionCount[f.userBId, default: 0] += 1 }
        }

        let nodes = try finalUsers.map { user in
            try GraphNodeDTO(
                id: user.requireID(),
                displayName: user.displayName,
                username: user.username,
                avatarURL: user.avatarURL,
                connectionCount: connectionCount[user.requireID()] ?? 0
            )
        }

        let edges = allFriendships.compactMap { f -> GraphEdgeDTO? in
            guard visibleUserIds.contains(f.userAId), visibleUserIds.contains(f.userBId) else { return nil }
            return GraphEdgeDTO(sourceId: f.userAId, targetId: f.userBId)
        }

        return GraphResponseDTO(nodes: nodes, edges: edges)
    }
}
