//  Created by Hannes Bergthaler on 04.12.20.

import Foundation

@available(iOS 13.0, *)
@objc
class WidgetService: NSObject {
    
    static let shared = WidgetService()
    
    private let actionHandler = ActionHandler()
    private let appService = AppService()
    
    // MARK: -
    
    @objc
    private override init() {}
    
    @objc
    static func sharedInstance() -> WidgetService {
        Self.shared
    }
    
    @objc
    func updateApp(id: String,
                   name: String,
                   installPath: String,
                   hdrSupported: Bool,
                   hidden: Bool) {
        let app = AppObject(id: id,
                          name: name,
                          installPath: installPath,
                          hdrSupported: hdrSupported,
                          hidden: hidden)
        
        actionHandler.start { close in
            appService
                .update(app)
                .sink { completion in
                    switch completion {
                    case .finished:
                        print("OUTAKES: Finished saving: \(app.name)")
                    case .failure(let error):
                        print("OUTAKES: \(error)")
                    }
                    
                    close()
                }
        }
    }
    
    @objc
    func testDatabase() {
        actionHandler.start { close in
            appService
                .publisher()
                .collect()
                .sink { _ in
                    close()
                } receiveValue: { apps in
                    apps.forEach { print("Saved: \($0)") }
                }
        }
        
    }
    
}
