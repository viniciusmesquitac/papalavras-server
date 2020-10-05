//
//  GuestController.swift
//
//
//  Created by Vinicius Mesquita on 29/09/20.
//

import Vapor
import Fluent

struct GuestSession: Content {
    let token: String
    let user: Guest
}

final class GuestController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        routes.group("guests") {
            $0.post(use: create)
            $0.get("list", use: list)
            $0.delete(":id", use: delete)
            $0.group(GuestToken.authenticator()) {
                $0.get("me", use: current)
            }
            $0.grouped(Guest.authenticator()).post("login", use: login)
        }
    }
    
    // GET
    func list(_ req: Request) throws -> EventLoopFuture<[Guest]> {
        return Guest.query(on: req.db).all()
    }
    
    // POST
    func create(_ req: Request) throws -> EventLoopFuture<GuestSession> {
        let input = try req.content.decode(Guest.Input.self)
        let guest = try Guest.create(from: input)
        var token: GuestToken!
    
        return guest.save(on: req.db).flatMap {
            
            guard let newToken = try? guest.createToken(source: .signup) else {
                return req.eventLoop.future(error: Abort(.internalServerError))
            }
            
            token = newToken
            return token.save(on: req.db)
            
        }.flatMapThrowing {
            GuestSession(token: token.value, user: guest)
            
        }
        
    }
    
    // DELETE
    func delete(_ req: Request) throws -> EventLoopFuture<Guest> {
        guard let id = req.parameters.get("id", as: User.IDValue.self) else {
            throw Abort(.badRequest)
        }
        return Guest.find(id, on: req.db).unwrap(or: Abort(.notFound))
            .flatMap { user in
                user.delete(on: req.db).map { user }
            }
    }
    
    // UPDATE
    func update(_ req: Request) throws -> EventLoopFuture<Guest>  {
        let input = try req.content.decode(Guest.Input.self)
        let guest = try Guest.create(from: input)
        return guest.update(on: req.db).map { guest }
    }
    
    // Generate a token for user.
    func login(_ req: Request) throws -> EventLoopFuture<GuestSession> {
        let guest = try req.auth.require(Guest.self)
        let token = try guest.createToken(source: .login)
        return token.save(on: req.db)
            .flatMapThrowing {
                GuestSession(token: token.value, user: guest)
            }
    }
    
    // Delete token from user.
    func logout(_ req: Request) throws -> EventLoopFuture<GuestSession> {
        let guest = try req.auth.require(Guest.self)
        return GuestToken.query(on: req.db)
            .filter(\.$guest.$id == guest.id!)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap { token in
                token.delete(on: req.db).map { GuestSession(token: token.value, user: guest) }
            }
    }
    
}

// Auxiliar Methods
extension GuestController {
    func current(req: Request) throws -> Guest.Output {
        try req.auth.require(Guest.self).public
    }
}
