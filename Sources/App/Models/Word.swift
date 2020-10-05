//
//  Word.swift
//
//
//  Created by Vinicius Mesquita on 30/09/20.
//
import Vapor
import Fluent

final class Word: Model {
    
    
    static var schema: String = "words"
    
    @ID(custom: .id)
    var id: Int?
    
    @Field(key: "count")
    var count: Int
 
    @Field(key: "word")
    var word: String
    
    @Field(key: "character")
    var character: String
    
    init() { }
    
    init(count: Int, word: String) {
        self.count = count
        self.word = word
    }
}

extension Word: Content {}
