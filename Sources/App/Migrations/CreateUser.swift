//
//  CreateUser.swift
//
//
//  Created by Vinicius Mesquita on 21/09/20.
//
import Fluent

struct CreateUser: Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema(User.schema)
            .id()
            .field("username", .string)
            .unique(on: "username")
            .field("email", .string)
            .field("display_name", .string)
            .unique(on: "email")
            .field("password", .string)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(User.schema).delete()
    }
}
