//
//  Matchup.swift
//  espn-ff
//
//  Created by Chris Paine on 10/7/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import Foundation

struct Matchup: Codable {
    var schedule: [Schedule]?
}

struct Schedule: Codable {
    var matchupPeriodId: Int?
    var away: MatchupTeam?
    var home: MatchupTeam?
}

struct MatchupTeam: Codable {
    var teamId: Int?
    var totalPoints: Double?
    var totalPointsLive: Double?
    var rosterForCurrentScoringPeriod: RosterForCurrentScoringPeriod?
}

extension MatchupTeam {
    var score: Double {
        if let totalPointsLive = totalPointsLive {
            return totalPointsLive
        }
        
        if let totalPoints = totalPoints {
            return totalPoints
        }
        
        return 0.0
    }
}

struct RosterForCurrentScoringPeriod: Codable {
    var entries: [Entry]?
}

extension RosterForCurrentScoringPeriod {
    var sortedEntries: [Entry]? {
        guard let entries = entries else { return nil }
        return entries.sorted(by: { $0.lineupSlotId ?? 0 < $1.lineupSlotId ?? 0 })
    }
}

struct Entry: Codable {
    var playerPoolEntry: PlayerPoolEntry?
    var status: String?
    var lineupSlotId: Int?
}

struct PlayerPoolEntry: Codable {
    var appliedStatTotal: Double?
    var player: Player?
    var rosterLocked: Bool?
    var status: String?
}
