//
//  Storable.swift
//  espn-ff
//
//  Created by Chris Paine on 10/16/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import Foundation

protocol Storable: Codable {
    
}

extension Storable {
    func save(with key: String) {
        NSLog("Saving storable: \(key)")
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: key)
        }
    }
    
    static func load(for key: String) -> Self? {
        NSLog("Loading storable: \(key)")
        guard let savedObject = UserDefaults.standard.object(forKey: key) as? Data else { return nil }
        return try? JSONDecoder().decode(Self.self, from: savedObject)
    }
}
