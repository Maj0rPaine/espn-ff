//
//  League.swift
//  espn-ff
//
//  Created by Chris Paine on 10/1/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import Foundation

struct League: Codable {
    var id: Int?
    var teams: [Team]?
    var name: String?
    
    private enum CodingKeys: String, CodingKey {
        case teams
        case settings
    }
    
    private enum SettingsCodingKeys: String, CodingKey {
        case name
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        teams = try container.decode(Array.self, forKey: .teams)
        let settings = try container.nestedContainer(keyedBy: SettingsCodingKeys.self, forKey: .settings)
        name = try settings.decode(String.self, forKey: .name)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(teams, forKey: .teams)
        var settings = container.nestedContainer(keyedBy: SettingsCodingKeys.self, forKey: .settings)
        try settings.encode(name, forKey: .name)
    }
}
