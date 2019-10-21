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

struct Schedule: Storable {    
    var matchupPeriodId: Int?
    var away: MatchupTeam?
    var home: MatchupTeam?
    var lastUpdate: String?
    
    private enum CodingKeys: String, CodingKey {
        case matchupPeriodId
        case away
        case home
        case lastUpdate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
       
        if let matchupPeriodId = try? container.decode(Int.self, forKey: .matchupPeriodId) {
            self.matchupPeriodId = matchupPeriodId
        }
        
        if let away = try? container.decode(MatchupTeam.self, forKey: .away) {
            self.away = away
        }
        
        if let home = try? container.decode(MatchupTeam.self, forKey: .home) {
            self.home = home
        }
        
        if let lastUpdate = try? container.decode(String.self, forKey: .lastUpdate) {
            self.lastUpdate = lastUpdate
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(matchupPeriodId, forKey: .matchupPeriodId)
        try container.encode(away, forKey: .away)
        try container.encode(home, forKey: .home)
        try container.encode(Date().formattedLocalTime(), forKey: .lastUpdate)
    }
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
