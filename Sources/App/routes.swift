import Fluent
import Vapor

func routes(_ app: Application) throws {
    
    app.get { req in
        return "Bem vindo ao papalavra-server! @"
    }
    
    app.get("hello") { req -> String in
        return "Hello, world!"
    }
    
    try app.register(collection: UserController())
    try app.register(collection: FriendController())
    try app.register(collection: GuestController())
    try app.register(collection: DictionaryController())
}
