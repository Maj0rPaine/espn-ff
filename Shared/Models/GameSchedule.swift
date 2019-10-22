//
//  GameSchedule.swift
//  espn-ff
//
//  Created by Chris Paine on 10/22/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import Foundation

struct GameSchedule: Codable {
    var events: [Game]
}

extension GameSchedule {
    var containsGamesInProgress: Bool {
        return events.contains(where: { $0.status == "in" })
    }
}

struct Game: Codable {
    var date: String?
    var status: String?
}
