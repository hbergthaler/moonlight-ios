//  Created by Hannes Bergthaler on 23.09.20.

import Foundation
import Combine
import RealmSwift

@available(iOS 13.0, *)
struct Database<OBJECT, NOTIFICATION> where OBJECT: RealmObject, NOTIFICATION: DatabaseNotification {
    typealias GetUpdateObject = (Realm) throws -> OBJECT
    typealias CreateNotificationInfo = (OBJECT) throws -> DatabaseNotification
    
    private var updateNotificationName: String {
        String(describing: OBJECT.self).appending(".update")
    }
    private var deleteNotificationName: String {
        String(describing: OBJECT.self).appending(".delete")
    }
    
    func database() throws -> Realm { try .init() }
    
    func count(filter: String? = nil) -> AnyPublisher<Int, DatabaseError> {
        Future<Int, DatabaseError> { promise in
            DispatchQueue(label: "Realm").async {
                autoreleasepool {
                    do {
                        let realm = try database()
                        let objects = getResults(from: realm,
                                                 filter: filter)
                        
                        promise(.success(objects.count))
                    } catch {
                        promise(.failure(convertDatabaseError(error: error)))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func publisher(filter: String? = nil,
                   sorting: String? = nil,
                   ascending: Bool = true) -> AnyPublisher<OBJECT, DatabaseError> {
        let subject = PassthroughSubject<OBJECT, DatabaseError>()
        
        DispatchQueue(label: "Realm").async {
            autoreleasepool {
                do {
                    let realm = try database()
                    let objects = getResults(from: realm,
                                             filter: filter,
                                             sorting: sorting,
                                             ascending: ascending)
                    
                    for object in objects {
                        subject.send(object)
                    }
                    
                    subject.send(completion: .finished)
                } catch {
                    subject.send(completion: .failure(convertDatabaseError(error: error)))
                }
            }
        }
        
        return subject.eraseToAnyPublisher()
    }
    
    func update(getUpdateObject: @escaping GetUpdateObject,
                createNotification: CreateNotificationInfo? = nil) -> AnyPublisher<UUID, DatabaseError> {
        Future<UUID, DatabaseError> { promise in
            DispatchQueue(label: "Realm").async {
                autoreleasepool {
                    do {
                        let realm = try database()
                        let object = try getUpdateObject(realm)
                        
                        try realm.write {
                            realm.add(object, update: .modified)
                        }
                        
                        let notification = try createNotification?(object) ?? DefaultDatabaseNotification(id: try object.convertId())
                        NotificationCenter.default.post(name: .name(updateNotificationName),
                                                        object: nil,
                                                        userInfo: notification.dictionary())
                        
                        
                        promise(.success(try object.convertId()))
                    } catch {
                        promise(.failure(convertDatabaseError(error: error)))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func delete(id: UUID,
                   createNotification: CreateNotificationInfo? = nil) -> AnyPublisher<UUID, DatabaseError> {
        delete(filter: "id = '\(id)'",
                  createNotification: createNotification)
    }
    
    func delete(filter: String,
                   createNotification: CreateNotificationInfo? = nil) -> AnyPublisher<UUID, DatabaseError> {
        let subject = PassthroughSubject<UUID, DatabaseError>()
        
        DispatchQueue(label: "Realm").async {
            autoreleasepool {
                do {
                    let realm = try database()
                    let objects = getResults(from: realm, filter: filter)
                    for object in objects {
                        let notification = try createNotification?(object) ?? DefaultDatabaseNotification(id: try object.convertId())
                        let id = try object.convertId()
                        
                        try realm.write {
                            realm.delete(object)
                        }
                        
                        subject.send(id)
                        NotificationCenter.default.post(name: .name(deleteNotificationName),
                                                        object: nil,
                                                        userInfo: notification.dictionary())
                    }
                    
                    subject.send(completion: .finished)
                } catch {
                    subject.send(completion: .failure(convertDatabaseError(error: error)))
                }
            }
        }
        
        return subject.eraseToAnyPublisher()
    }
    
    func onUpdate() -> AnyPublisher<NOTIFICATION, Never> {
        receiveNotification(name: updateNotificationName)
    }
    
    func onDelete() -> AnyPublisher<NOTIFICATION, Never> {
        receiveNotification(name: deleteNotificationName)
    }
    
    func convertDatabaseError(error: Error) -> DatabaseError {
        if let error = error as? DatabaseError {
            return error
        }
        
        return .unkown(error: error)
    }
    
    func duplicate<Content>(to content: Content, type: Content.Type) throws -> Content where Content: Codable, Content: Identifiable {
        // Encode content
        let data = try JSONEncoder().encode(content)
        // Convert to dictionary
        guard var jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw DatabaseError.mapping
        }
        // Insert device token
        jsonObject["id"] = UUID().uuidString
        // Convert to data
        let newData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
        return try JSONDecoder().decode(type, from: newData)
    }
    
    // MARK: - Private
    
    private func getResults(from realm: Realm,
                            filter: String? = nil,
                            sorting: String? = nil,
                            ascending: Bool = true) -> Results<OBJECT> {
        var objects = realm.objects(OBJECT.self)
        
        if let filter = filter {
            objects = objects.filter(filter)
        }
        if let sorting = sorting {
            objects = objects.sorted(byKeyPath: sorting, ascending: ascending)
        }
        
        return objects
    }
    
    private func receiveNotification(name: String) -> AnyPublisher<NOTIFICATION, Never> {
        NotificationCenter
            .default
            .publisher(for: .name(name))
            .compactMap { NOTIFICATION(userInfo: $0.userInfo) }
            .eraseToAnyPublisher()
    }
    
}
