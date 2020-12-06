//  Created by Hannes Bergthaler on 06.12.20.

import Foundation

class AppRealmObject: RealmObject {
    
    @objc dynamic var name: String = ""
    @objc dynamic var installPath: String = ""
    @objc dynamic var hdrSupported: Bool = false
    @objc dynamic var hidden: Bool = false
    
}

// MARK: - Map to object

extension AppRealmObject {
    
    func object() throws -> AppObject {
        .init(id: id,
              name: name,
              installPath: installPath,
              hdrSupported: hdrSupported,
              hidden: hidden)
    }
    
}

// MARK: - Map to realm object

extension AppObject {
    
    func realmObject() -> AppRealmObject {
        let realmObject = AppRealmObject()
        realmObject.id = id
        realmObject.name = name
        realmObject.installPath = installPath
        realmObject.hdrSupported = hdrSupported
        realmObject.hidden = hidden
        
        return realmObject
    }
    
}
