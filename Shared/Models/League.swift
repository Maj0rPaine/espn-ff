//
//  League.swift
//  espn-ff
//
//  Created by Chris Paine on 10/1/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import Foundation
import CoreData

struct League: Codable {
    var leagueId: Int?
    var scoringPeriodId: Int?
    var teams: [Team]?
    var name: String?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case scoringPeriodId
        case teams
        case settings
    }
    
    private enum SettingsCodingKeys: String, CodingKey {
        case name
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let id = try? container.decode(Int.self, forKey: .id) {
            self.leagueId = id
        }
        
        if let scoringPeriodId = try? container.decode(Int.self, forKey: .scoringPeriodId) {
            self.scoringPeriodId = scoringPeriodId
        }
        
        if let teams = try? container.decode(Array<Team>.self, forKey: .teams) {
            self.teams = teams
        }
        
        if let settings = try? container.nestedContainer(keyedBy: SettingsCodingKeys.self, forKey: .settings),
            let name = try? settings.decode(String.self, forKey: .name) {
            self.name = name
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(leagueId, forKey: .id)
        try container.encode(scoringPeriodId, forKey: .scoringPeriodId)
        try container.encode(teams, forKey: .teams)
        var settings = container.nestedContainer(keyedBy: SettingsCodingKeys.self, forKey: .settings)
        try settings.encode(name, forKey: .name)
    }
}

extension League {
    init(entity: LeagueEntity) {
        self.leagueId = Int(entity.id)
        self.scoringPeriodId = Int(entity.scoringPeriodId)
        self.teams = entity.teams?.allObjects as? [Team]
        self.name = entity.name
    }
}
