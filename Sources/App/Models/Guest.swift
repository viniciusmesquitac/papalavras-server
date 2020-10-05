//
//  Guest.swift
//
//
//  Created by Vinicius Mesquita on 29/09/20.
//

import Vapor
import Fluent

final class Guest: Model {
    
    static var schema: String = "guests"
    
    init() { }
    
    @ID()
    var id: UUID?
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "display_name")
    var displayName: String
    
    init(id: UUID? = nil, username: String, displayName: String) {
        self.id = id
        self.username = username
        self.displayName = displayName
    }
    
}

extension Guest: Content { }


extension Guest {
    
    struct Input: Content {
        var username: String
    }
    
    struct Output: Content {
        var id: UUID?
        var username: String
        var displayName: String
    }
    
    static func create(from input: Input) throws -> Guest {
        let hash = [UInt8].random(count: 16).hashValue
        let username = String("guest@\(hash)")
        return Guest(username: username, displayName: input.username)
    }
    
    func createToken(source: GuestSessionSource) throws -> GuestToken {
        let calendar = Calendar(identifier: .gregorian)
        let expiryDate = calendar.date(byAdding: .year, value: 1, to: Date())
        let token = [UInt8].random(count: 16).base64
        return try GuestToken(guestId: requireID(), token: token, source: source, expiresAt: expiryDate)
    }
    
    var `public`: Output {
        Output(id: self.id, username: self.username, displayName: self.displayName)
    }
    
}


extension Guest: ModelAuthenticatable {
    
    
    static let usernameKey = \Guest.$username
    static let passwordHashKey = \Guest.$username
    
    func verify(password: String) throws -> Bool {
        password == self.username ? true : false
    }
}
