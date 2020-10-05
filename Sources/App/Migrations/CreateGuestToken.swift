//
//  CreateGuestToken.swift
//
//
//  Created by Vinicius Mesquita on 29/09/20.
//
import Fluent

struct CreateGuestToken: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        
        database.schema(GuestToken.schema)
            .id()
            .field("guest_id", .uuid)
            .foreignKey("guest_id", references: "guests", "id", onDelete: .cascade)
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
