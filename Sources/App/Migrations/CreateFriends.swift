//
//  CreateFriend.swift
//
//
//  Created by Vinicius Mesquita on 25/09/20.
//
import Fluent

struct CreateFriend: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema(Friend.schema)
            .id()
            .field("username", .string)
            .field("userID", .uuid)
            .field("friendId", .uuid)
            .foreignKey("userID", references: "users", "id", onDelete: .cascade)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Friend.schema).delete()
    }
}
