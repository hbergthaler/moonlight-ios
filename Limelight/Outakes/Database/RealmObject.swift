//  Created by Hannes Bergthaler on 29.09.20.

import Foundation
import RealmSwift

class RealmObject: Object, Codable, Identifiable {
    
    @objc dynamic var id: String = UUID().uuidString
    
    override static func primaryKey() -> String? { "id" }
    
    func convertId() throws -> UUID {
        guard let id = UUID(uuidString: id) else {
            throw DatabaseError.mapping
        }
        
        return id
    }

}
 
