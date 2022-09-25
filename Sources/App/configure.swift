import Fluent
import FluentPostgresDriver
import Vapor

extension Environment {
    
    static var databaseURL: URL? {
        if let urlString = Environment.get("DATABASE_URL"), let url = URL(string: urlString + "?sslmode=require") {
            return url
        }
        return nil
    }
}

public func configure(_ app: Application) throws {

    if let databaseUrl = Environment.databaseURL {
        var config = PostgresConfiguration(url: databaseUrl)!
        config.tlsConfiguration = TLSConfiguration.forClient(certificateVerification: .none)
        app.databases.use(.postgres(configuration: config), as: .psql)
    } else {
        app.databases.use(.postgres(
            hostname: Environment.get("DATABASE_HOST") ?? "",
            username: Environment.get("DATABASE_USERNAME") ?? "",
            password: Environment.get("DATABASE_PASSWORD") ?? "",
            database: Environment.get("DATABASE_NAME") ?? "",
            tlsConfiguration: .forClient(certificateVerification: .none)
        ), as: .psql)
    }

    try routes(app)
    
    if app.environment == .development {
        try app.autoMigrate().wait()
    }
}
