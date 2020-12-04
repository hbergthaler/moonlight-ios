//  Created by Hannes Bergthaler on 23.09.20.

import Foundation

// MARK: - Encode to dictionary

extension Encodable {
    
    func dictionary() -> [String: Any]? {
        do {
            let data = try JSONEncoder().encode(self)
            
            guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
                throw NSError()
            }
            
            return dictionary
        } catch {
            #if DEBUG
            // TODO: os log
            print("Error: Encode to dictionary")
            #endif
            return nil
        }
    }
    
}

// MARK: - Decode from dictionary

extension Decodable {
    
    init?(userInfo: [AnyHashable: Any]?) {
        guard let userInfo = userInfo else { return nil }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: userInfo, options: .fragmentsAllowed)
            self = try JSONDecoder().decode(Self.self, from: data)
        } catch {
            #if DEBUG
            // TODO: os log
            print("Error: Decode from dictionary")
            #endif
            return nil
        }
    }
    
}
