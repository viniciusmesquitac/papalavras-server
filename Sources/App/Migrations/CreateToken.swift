//
//  CreateToken.swift
//
//
//  Created by Vinicius Mesquita on 21/09/20.
//
import Fluent

struct CreateToken: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        
        database.schema(Token.schema)
            .id()
            .field("user_id", .uuid)
            .foreignKey("user_id", references: "users", "id", onDelete: .cascade)
            .field("value", .string, .required).unique(on: "value")
            .field("source", .int, .required)
            .field("created_at", .datetime, .required)
            .field("expires_at", .datetime)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Token.schema).delete()
    }
}
