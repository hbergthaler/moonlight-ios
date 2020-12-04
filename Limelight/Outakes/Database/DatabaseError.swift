//  Created by Hannes Bergthaler on 29.09.20.

enum DatabaseError: Error {
    case mapping
    case objectNotFound
    case duplicateItem
    case unkown(error: Error)
}
