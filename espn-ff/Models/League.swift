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

extension League {
    static func getLeague(leagueId: String, completion: @escaping (League?, Error?) -> Void) {
        if let urlComponents = URLComponents(string: "https://fantasy.espn.com/apis/v3/games/ffl/seasons/2019/segments/0/leagues/\(leagueId)") {
            guard let url = urlComponents.url else {
                return
            }
            
            URLSession(configuration: .default).dataTask(with: url) { data, response, error in
                if let error = error {
                    completion(nil, error)
                } else if
                    let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200,
                    let league = try? JSONDecoder().decode(League.self, from: data) {
                    completion(league, nil)
                } else {
                    completion(nil, nil)
                }
            }.resume()
        }
    }
    
    static func getTeam(leagueId: String, teamId: String, completion: @escaping (Team?, Error?) -> Void) {
        if var urlComponents = URLComponents(string: "https://fantasy.espn.com/apis/v3/games/ffl/seasons/2019/segments/0/leagues/\(leagueId)") {
            urlComponents.queryItems = [
                URLQueryItem(name: "view", value: "mTeam"),
                URLQueryItem(name: "view", value: "mSettings")
            ]
            guard let url = urlComponents.url else {
                return
            }
            
            URLSession(configuration: .default).dataTask(with: url) { data, response, error in
                if let error = error {
                    completion(nil, error)
                } else if
                    let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200,
                    let league = try? JSONDecoder().decode(League.self, from: data) {
                    if let team = league.teams?.first(where: { $0.owners?.first == teamId }) {
                        completion(team, nil)
                    } else {
                        completion(nil, nil)
                    }
                } else {
                    completion(nil, nil)
                }
            }.resume()
        }
    }
}
