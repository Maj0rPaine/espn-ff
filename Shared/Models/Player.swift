//
//  Player.swift
//  espn-ff
//
//  Created by Chris Paine on 10/10/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import Foundation

enum PlayerStatus: String, Codable {
    case active = "ACTIVE"
    case questionable = "QUESTIONABLE"
    case doubtful = "DOUBTFUL"
    case out = "OUT"
    case injuryReserve = "INJURY_RESERVE"
    
    var code: String {
        switch self {
        case .active: return ""
        case .questionable: return "Q"
        case .doubtful: return "D"
        case .out: return "Out"
        case .injuryReserve: return "IR"
        }
    }
}

struct Player: Codable {
    var firstName: String?
    var fullName: String?
    var id: Int?
    var lastName: String?
    var injuryStatus: PlayerStatus?
}

extension Player {
    var shortName: String? {
        guard let firstInitial = firstName?.prefix(1),
            let lastName = lastName,
            !lastName.contains("D/ST") else { return fullName }
        return "\(firstInitial). \(lastName)"
    }
}
