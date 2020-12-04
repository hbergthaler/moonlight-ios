//  Created by Hannes Bergthaler on 04.12.20.

import Foundation

@objc
class WidgetService: NSObject {
    
    static let shared = WidgetService()
    
    // MARK: -
    
    @objc
    private override init() {}
    
    @objc
    static func sharedInstance() -> WidgetService {
        Self.shared
    }
    
    @objc
    func update(app: AppObject) {
        print("\(app.name)")
    }
    
}

@objc
class AppObject: NSObject {
    let id: String
    let name: String
    let installPath: String
    let hdrSupported: Bool
    let hidden: Bool
    
    // MARK: -
    
    @objc
    init(id: String,
         name: String,
         installPath: String,
         hdrSupported: Bool,
         hidden: Bool) {
        self.id = id
        self.name = name
        self.installPath = installPath
        self.hdrSupported = hdrSupported
        self.hidden = hidden
    }
    
}
