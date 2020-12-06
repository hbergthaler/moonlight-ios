//  Created by Hannes Bergthaler on 06.12.20.

import Combine

@available(iOS 13, *)
struct AppService {
    
    private let database = Database<AppRealmObject, DefaultDatabaseNotification>()
    
    // MARK: -
    
    func publisher() -> AnyPublisher<AppObject, DatabaseError> {
        database
            .publisher()
            .tryMapToObject { try $0.object() }
    }
    
    func update(_ object: AppObject) -> AnyPublisher<String, DatabaseError> {
        database
            .update { _ in object.realmObject() }
    }
    
    func delete(id: String) -> AnyPublisher<String, DatabaseError> {
        database
            .delete(filter: "id = '\(id)'")
    }
    
}

