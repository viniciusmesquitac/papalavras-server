import Fluent
import FluentPostgresDriver
import Vapor

extension Environment {
    
    static var databaseURL: URL? {
        if let urlString = Environment.get("DATABASE_URL"), let url = URL(string: urlString) {
            return url
        }
        return nil
    }
}


// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    if let databaseUrl = Environment.databaseURL {
        try app.databases.use(.postgres(url: databaseUrl), as: .psql)
    } else {
        app.databases.use(.postgres(
            hostname: Environment.get("DATABASE_HOST") ?? "localhost",
            username: Environment.get("DATABASE_USERNAME") ?? "vinicius",
            password: Environment.get("DATABASE_PASSWORD") ?? "",
            database: Environment.get("DATABASE_NAME") ?? "papalavrasdb",
            tlsConfiguration: .forClient(certificateVerification: .none)
        ), as: .psql)
    }

    app.migrations.add(CreateUser())
    app.migrations.add(CreateToken())
    app.migrations.add(CreateGuest())
    app.migrations.add(CreateGuestToken())
    app.migrations.add(CreateFriend())

    // register routes
    try routes(app)
    
    if app.environment == .development {
        try app.autoMigrate().wait()
    }
}
