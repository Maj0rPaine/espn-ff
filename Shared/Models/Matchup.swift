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

//extension Schedule {
//    var homeScoreRounded: String? {
//        guard let homeTeamScore = homeTeamScore else { return nil }
//        return String(format: "%.1f", homeTeamScore)
//    }
//
//    var awayScoreRounded: String? {
//        guard let awayTeamScore = awayTeamScore else { return nil }
//        return String(format: "%.1f", awayTeamScore)
//    }
//}

struct MatchupTeam: Codable {
    var teamId: Int?
    var totalPoints: Double?
}
