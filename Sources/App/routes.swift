import Fluent
import Vapor

func routes(_ app: Application) throws {
    
    app.get { req in
        return "Bem vindo ao papalavra-server! @"
    }

    try app.register(collection: DictionaryController())
}
