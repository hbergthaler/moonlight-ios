//  Created by Hannes Bergthaler on 29.09.20.

import Foundation

protocol DatabaseNotification: Codable {
    var id: String { get }
}

struct DefaultDatabaseNotification: DatabaseNotification {
    let id: String
}
