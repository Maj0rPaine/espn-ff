//
//  Team.swift
//  espn-ff
//
//  Created by Chris Paine on 10/1/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import Foundation

struct Team: Codable {
    var id: Int?
    var abbrev: String?
    var location: String?
    var nickname: String?
    var logo: String?
    var owners: [String]?
}

extension Team {
    var description: String {
        guard let location = location,
            let nickname = nickname else { return "" }
        return "\(location) \(nickname)"
    }
}
