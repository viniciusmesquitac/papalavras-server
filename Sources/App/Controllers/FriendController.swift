//
//  FriendController.swift
//
//
//  Created by Vinicius Mesquita on 25/09/20.
//

import Fluent
import Vapor

final class FriendController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        routes.group("friends") {
            $0.group(Token.authenticator()) {
                $0.post(":id", use: addFriend)
                $0.get(use: getFriends)
                $0.delete(":id", use: delete)
            }
            $0.get(":id", use: getFriend)
            $0.get("list", use: list)
        }
    }
    
    // POST
    func addFriend(_ req: Request) throws -> EventLoopFuture<Friend> {
        guard let friendId = req.parameters.get("id", as: User.IDValue.self) else {
            throw Abort(.badRequest)
        }
        
        let me = try req.auth.require(User.self)
        
        return User.find(friendId, on: req.db)
            .unwrap(or: Abort(.badRequest))
            .flatMapThrowing { user -> (Friend, Friend) in
                guard let userId = me.id else { throw Abort(.badRequest) }
                
                // Friend to save in with my user id
                let input = Friend.Input(username: user.username, userId: userId, friendId: friendId)
                let myFriend = try Friend.create(from: input)
                
                // Me as a friend to save in my user friend
                let meInput = Friend.Input(username: me.username, userId: user.id!, friendId: me.id!)
                let meAsFriend = try Friend.create(from: meInput)
                return (myFriend, meAsFriend)
                
            }.flatMap { myFriend, meAsAFriend in
                myFriend.save(on: req.db)
                    .flatMap { meAsAFriend.save(on: req.db) }
                    .transform(to: myFriend)
            }
    }
    
    // GET
    func getFriends(_ req: Request) throws -> EventLoopFuture<[Friend]> {
        let me = try req.auth.require(User.self)
        let query = Friend.query(on: req.db)
        guard let id = me.id else { throw Abort(.badRequest) }
        return query.filter(\.$user.$id == id).all()
    }
    
    
    // GET
    func getFriend(_ req: Request) throws -> EventLoopFuture<[Friend]> {
        guard let id = req.parameters.get("id", as: User.IDValue.self) else {
            throw Abort(.badRequest)
        }
        let query = Friend.query(on: req.db)
        return query.filter(\.$user.$id == id).all()
    }
    
    // DELETE
    func delete(_ req: Request) throws -> EventLoopFuture<Friend> {
        guard let id = req.parameters.get("id", as: Friend.IDValue.self) else {
            throw Abort(.badRequest)
        }
        
        // Find and delete from my list friend.
        return Friend.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { friend in
                
                friend.delete(on: req.db).flatMap {
                    let query = Friend.query(on: req.db)
                    return query.filter(\.$friendId == friend.$user.id).first()
                        .unwrap(or: Abort(.badRequest))
                        .flatMap { meFriend in
                            meFriend.delete(on: req.db)
                        }
                }.map { friend }
            }
        
        
        // Delete from me from the list of my friend.
    }
    
    func list(_ req: Request) throws -> EventLoopFuture<[Friend]> {
        return Friend.query(on: req.db).all()
    }
    
}
