import Fluent
import Vapor

final class Friendship: Model, @unchecked Sendable {
    static let schema = "friendships"

    @ID(key: .id) var id: UUID?
    @Field(key: "user_a_id") var userAId: UUID
    @Field(key: "user_b_id") var userBId: UUID
    @Field(key: "status") var status: String
    @Timestamp(key: "created_at", on: .create) var createdAt: Date?

    init() {}

    init(id: UUID? = nil, userAId: UUID, userBId: UUID, status: String = "pending") {
        self.id = id
        // Always store as min/max to enforce uniqueness
        let a = userAId.uuidString < userBId.uuidString ? userAId : userBId
        let b = userAId.uuidString < userBId.uuidString ? userBId : userAId
        self.userAId = a
        self.userBId = b
        self.status = status
    }
}
