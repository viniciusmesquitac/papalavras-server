
//
//  CreateGuest.swift
//
//
//  Created by Vinicius Mesquita on 29/09/20.
//
import Fluent

struct CreateGuest: Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema(Guest.schema)
            .id()
            .field("username", .string)
            .unique(on: "username")
            .field("display_name", .string)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(User.schema).delete()
    }
}
