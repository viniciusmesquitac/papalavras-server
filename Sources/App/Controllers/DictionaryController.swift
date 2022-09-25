//
//  DictionaryController.swift
//
//
//  Created by Vinicius Mesquita on 30/09/20.
//

import Fluent
import Vapor

final class DictionaryController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        routes.group("words") {
            $0.get("random", use: random)
            $0.get("verify", ":word", use: verify)
            $0.get("random", ":character", use: character)
        }
    }
    
    func random(_ req: Request) throws -> EventLoopFuture<Word> {
        let randomRange = Int.random(in: 0...270000)
        
        return Word.query(on: req.db)
            .range(randomRange..<randomRange+10)
            .all()
            .flatMap { words in
                var searchWord: String = "Teste"
                
                if let word  = words.randomElement()?.word {
                    searchWord = word
                }
                
                return Word.query(on: req.db)
                    .filter(\.$word == searchWord).first()
                    .unwrap(or: Abort(.internalServerError))
        }
    }
    
    func character(_ req: Request) throws -> EventLoopFuture<Word> {
        
        guard let param = req.parameters.get("character", as: String.self) else {
            throw Abort(.badRequest)
        }
        let randomRange = Int.random(in: 0..<RandomRange.max(character: param))
        
        return Word.query(on: req.db).filter(\.$character == param)
            .range(randomRange..<randomRange+10)
            .all()
            .flatMap { words in
                var searchWord: String = "Teste"
                if let word  = words.randomElement()?.word {
                    searchWord = word
                }
                return Word.query(on: req.db)
                    .filter(\.$word == searchWord).first()
                    .unwrap(or: Abort(.internalServerError))
        }
    }
    
    func verify(_ req: Request) throws -> EventLoopFuture<Word> {
        guard let param = req.parameters.get("word", as: String.self) else {
            throw Abort(.badRequest)
        }
        return Word.query(on: req.db).filter(\.$word == param).first()
            .unwrap(or: Abort(.internalServerError))
    }
    
}


enum RandomRange: String {
    
    case A, B, C, D, E,
         F, G, H, I, J,
         K, L, M, N, O,
         P, Q, R, S, T,
         U, V, W, X, Y,
         Z
    
    private var resul: Int {
        switch self {
        case .A: return 29055; case .B: return 13137; case .C: return 31947;
        case .D: return 12122; case .E: return 2191;  case .F: return 10038;
        case .G: return 9568;  case .H: return 9278;  case .I: return 8914;
        case .J: return 3281;  case .K: return 95;    case .L: return 9271;
        case .M: return 22884; case .N: return 6352;  case .O: return 7542;
        case .P: return 24323; case .Q: return 2984;  case .R: return 8735;
        case .S: return 13503; case .T: return 16389; case .U: return 2626;
        case .V: return 5245;  case .W: return 46;    case .X: return 806;
        case .Y: return 16;    case .Z: return 955;
        }
    }
    
    static func max(character: RandomRange.RawValue) -> Int {
        guard let result = RandomRange.init(rawValue: character)?.resul else {
            return 10
        }
        return result
    }
}
