//
//  UserController.swift
//
//
//  Created by Vinicius Mesquita on 18/09/20.
//

import Vapor
import Fluent

struct Session: Content {
    let token: String
    let user: User
}

final class UserController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        routes.group("users") {
            $0.post(use: create)
            $0.get(use: list)
            $0.delete(":id", use: delete)
            $0.get("search", ":username", use: getUserByUsername)
            $0.get(":id", "friends", use: friends)
            $0.group(Token.authenticator()) {
                $0.get("me", use: current)
            }
            $0.grouped(User.authenticator()).post("login", use: login)
        }
    }
    
    // GET
    func list(_ req: Request) throws -> EventLoopFuture<[User]> {
        return User.query(on: req.db).all()
    }
    
    // POST
    func create(_ req: Request) throws -> EventLoopFuture<Session> {
        let input = try req.content.decode(User.Input.self)
        let user = try User.create(from: input)
        var token: Token!
        
        return user.save(on: req.db).flatMap {
            
            guard let newToken = try? user.createToken(source: .signup) else {
                return req.eventLoop.future(error: Abort(.internalServerError))
            }
            
            token = newToken
            return token.save(on: req.db)
            
        }.flatMapThrowing {
            Session(token: token.value, user: user)
        }
    }
    
    // DELETE
    func delete(_ req: Request) throws -> EventLoopFuture<User> {
        guard let id = req.parameters.get("id", as: User.IDValue.self) else {
            throw Abort(.badRequest)
        }
        
        return User.find(id, on: req.db).unwrap(or: Abort(.notFound))
            .flatMap { user in
                user.delete(on: req.db).map { user }
            }
    }
    
    // GET USER
    func getUserByUsername(_ req: Request) throws -> EventLoopFuture<[User]>  {
        guard let username = req.parameters.get("username", as: String.self) else {
            throw Abort(.badRequest)
        }
        let query = User.query(on: req.db)
        return query.filter("username", .equal, username).all()
    }
    
    // UPDATE
    func update(_ req: Request) throws -> EventLoopFuture<User>  {
        let input = try req.content.decode(User.Input.self)
        let user = try User.create(from: input)
        return user.update(on: req.db).map { return user }
    }
    
    // Generate a token for user.
    func login(_ req: Request) throws -> EventLoopFuture<Session> {
        let user = try req.auth.require(User.self)
        let token = try user.createToken(source: .login)
        return token.save(on: req.db)
            .flatMapThrowing {
                Session(token: token.value, user: user)
            }
    }
    
    // Delete token from user.
    func logout(_ req: Request) throws -> EventLoopFuture<Session> {
        let user = try req.auth.require(User.self)
        return Token.query(on: req.db)
            .filter(\.$user.$id == user.id!)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap { token in
                token.delete(on: req.db).map { Session(token: token.value, user: user) }
            }
    }
    
}

// Auxiliar Methods
extension UserController {
    
    
    func current(req: Request) throws -> User.Output {
        try req.auth.require(User.self).public
    }
    
    func friends(req: Request) throws -> EventLoopFuture<[Friend]> {
        guard let id = req.parameters.get("id", as: User.IDValue.self) else {
            throw Abort(.badRequest)
        }
        return Friend.query(on: req.db).filter(\.$user.$id == id).all()
    }
    
}
