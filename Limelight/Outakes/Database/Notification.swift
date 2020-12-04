//  Created by Hannes Bergthaler on 11.09.20.

import Foundation

// MARK: - Create quict notification name

extension Notification.Name {
    
    static func name(_ name: String) -> Notification.Name {
        .init(name)
    }
    
}
