//
//  User.swift
//
//
//  Created by Vinicius Mesquita on 18/09/20.
//

import Vapor
import Fluent

final class User: Model {
    
    static var schema: String = "users"
    
    init() { }
    
    @ID()
    var id: UUID?
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "display_name")
    var displayName: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "password")
    var password: String
    
    @Children(for: \.$user)
    var friends: [Friend]
    
    init(id: UUID? = nil, username: String, email: String, password: String, displayName: String) {
        self.id = id
        self.username = username
        self.email = email
        self.displayName = displayName
        self.password = password
    }
}

extension User {
    
    struct Input: Content {
        var username: String
        var email: String
        var password: String
    }

    struct Output: Content {
        var id: UUID?
        var username: String
        var email: String
        var displayName: String
        var friends: [Friend]?
    }
    
    static func create(from input: Input) throws -> User {
        return User(username: input.username, email: input.email,
                    password: try Bcrypt.hash(input.password),
                    displayName: input.username)
    }
    
    func createToken(source: SessionSource) throws -> Token {
        let calendar = Calendar(identifier: .gregorian)
        let expiryDate = calendar.date(byAdding: .year, value: 1, to: Date())
        let token = [UInt8].random(count: 16).base64
        return try Token(userId: requireID(), token: token, source: source, expiresAt: expiryDate)
    }
    
    var `public`: Output {
        Output(id: self.id, username: self.username, email: self.email, displayName: self.displayName)
    }
    
}

extension User: ModelAuthenticatable {
    
    static let usernameKey = \User.$email
    static let passwordHashKey = \User.$password
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
}

extension User: Content { }
