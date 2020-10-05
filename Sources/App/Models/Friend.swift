//
//  Friend.swift
//
//
//  Created by Vinicius Mesquita on 25/09/20.
//
import Vapor
import Fluent

final class Friend: Model {
    
    static var schema: String = "friends"
    
    init() { }
    
    @ID()
    var id: UUID?
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "friendId")
    var friendId: UUID?
 
    @Parent(key: "userID")
    var user: User
    
    init(id: UUID? = nil, username: String, userId: User.IDValue, friendId: Friend.IDValue) {
        self.id = id
        self.username = username
        self.$user.id = userId
        self.friendId = friendId
    }
}

extension Friend {
    
    struct Input: Content {
        var username: String
        var userId: User.IDValue
        var friendId: Friend.IDValue
    }
    
    static func create(from input: Input) throws -> Friend {
        return Friend(username: input.username, userId: input.userId, friendId: input.friendId)
    }
}

extension Friend: Content {}
