//  Created by Hannes Bergthaler on 15.07.20.

import Foundation
import Combine

@available(iOS 13.0, *)
final class ActionHandler {
    typealias CloseableAction = (_ closeSession: @escaping () -> Void) -> AnyCancellable
    typealias Action = () -> AnyCancellable
    
    lazy var storage: Set<AnyCancellable> = []
    
    // MARK: - Private
    
    private lazy var sessionActions: [UUID: AnyCancellable] = [:]
    
    // MARK: -
    
    func start(action: CloseableAction) {
        let session = UUID()
        sessionActions[session] = action { [weak self] in
            self?.sessionActions.removeValue(forKey: session)
        }
    }
    
    func store(store: Action) {
        store().store(in: &storage)
    }
    
    func cancel() {
        sessionActions.values.forEach { action in
            action.cancel()
        }
        storage.forEach { action in
            action.cancel()
        }
        
        sessionActions = [:]
        storage = []
    }
    
}
