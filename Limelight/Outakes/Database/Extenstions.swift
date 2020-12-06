//  Created by Hannes Bergthaler on 29.09.20.

import Foundation
import RealmSwift
import Combine

extension Realm {
    
    func object<Element>(ofType type: Element.Type,
                         forId id: UUID) throws -> Element where Element : Object {
        guard let object = object(ofType: type,
                                  forPrimaryKey: id.uuidString) else {
            throw DatabaseError.objectNotFound
        }
        
        return object
    }
    
}

@available(iOS 13, *)
extension Publisher where Output: RealmObject {
    
    func tryMapToObject<T>(_ transform: @escaping (Output) throws -> T) -> AnyPublisher<T, DatabaseError> {
        tryMap { (output) -> T in
            try transform(output)
        }
        .mapError { (error) -> DatabaseError in
            if let error = error as? DatabaseError {
                return error
            }
            
            return .unkown(error: error)
        }
        .eraseToAnyPublisher()
    }
    
    func convertToDatabaseError() -> AnyPublisher<Output, DatabaseError> {
        mapError { error -> DatabaseError in
            if let error = error as? DatabaseError {
                return error
            }
            
            return .unkown(error: error)
        }
        .eraseToAnyPublisher()
    }
    
}

// MARK: - Removes receive value method on void publishers

@available(iOS 13, *)
extension Publisher {
    
    public func sink(receiveCompletion: @escaping ((Subscribers.Completion<Self.Failure>) -> Void)) -> AnyCancellable {
        sink(receiveCompletion: receiveCompletion) { _ in
            // Do nothing
        }
    }
    
}
