//
//  GuestToken.swift
//
//
//  Created by Vinicius Mesquita on 21/09/20.
//
import Vapor
import Fluent


enum GuestSessionSource: Int, Content {
    case signup
    case login
}

final class GuestToken: Model {
    
    static let schema = "guest_tokens"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "guest_id")
    var guest: Guest
    
    @Field(key: "value")
    var value: String
    
    @Field(key: "source")
    var source: GuestSessionSource
    
    @Field(key: "expires_at")
    var expiresAt: Date?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init() {}
    
    init(id: UUID? = nil, guestId: Guest.IDValue, token: String,
         source: GuestSessionSource, expiresAt: Date?) {
        self.id = id
        self.$guest.id = guestId
        self.value = token
        self.source = source
        self.expiresAt = expiresAt
    }
}


extension GuestToken: ModelTokenAuthenticatable {
    
    static let valueKey = \GuestToken.$value
    static let userKey = \GuestToken.$guest
    
    var isValid: Bool {
        guard let expiryDate = expiresAt else {
            return true
        }
        return expiryDate > Date()
    }
    
}

extension GuestToken: Content {}
