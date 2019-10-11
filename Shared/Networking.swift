//
//  Networking.swift
//  espn-ff
//
//  Created by Chris Paine on 10/2/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import Foundation

class Networking {
    typealias JSONTaskCompletionHandler = (Decodable?, NetworkError?) -> Void
    
    static let shared = Networking()
        
    let baseURL = "https://fantasy.espn.com/apis/v3/games/ffl/seasons/2019/segments/0/leagues/"

    var session: URLSession!

    var dataTask: URLSessionDataTask?
    
    init() {
        session = URLSession(configuration: .default)
    }
    
    func request<T: Decodable>(_ url: URL?, decode: @escaping (Decodable) -> T?, completion: @escaping (NetworkResult<T, NetworkError>) -> Void) {
        guard let url = url else { return }
        
        dataTask?.cancel()
        
        dataTask = decodingTask(with: url, decodingType: T.self) { (json , error) in
            defer {
                self.dataTask = nil
            }
            
            DispatchQueue.main.async {
                guard let json = json else {
                    if let error = error {
                        completion(NetworkResult.failure(error))
                    } else {
                        completion(NetworkResult.failure(.invalidData))
                    }
                    return
                }
                
                if let value = decode(json) {
                    completion(.success(value))
                } else {
                    completion(.failure(.jsonParsingFailure))
                }
            }
        }
        
        dataTask?.resume()
    }

    func decodingTask<T: Decodable>(with url: URL, decodingType: T.Type, completionHandler completion: @escaping JSONTaskCompletionHandler) -> URLSessionDataTask {
        #if DEBUG
        print(url)
        #endif
        return session.dataTask(with: url) { data, response, error in
            if let error = error as NSError?, error.code == NSURLErrorNotConnectedToInternet {
                completion(nil, .noInternet)
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(nil, .requestFailed)
                return
            }
            
            switch response.statusCode {
            case 200:
                if let data = data {
                    do {
                        let genericModel = try JSONDecoder().decode(decodingType, from: data)
                        completion(genericModel, nil)
                    } catch {
                        completion(nil, .jsonConversionFailure)
                    }
                } else {
                    completion(nil, .invalidData)
                }
            case 401:
                completion(nil, .authenticationFailed)
            default:
                completion(nil, .responseUnsuccessful)
            }
        }
    }
}

extension Networking {
    func getLeague(leagueId: Int32, completion: @escaping (League?, Error?) -> Void) {
        guard var urlComponents = URLComponents(string: "\(baseURL)\(leagueId)") else { return }
        urlComponents.queryItems = [
            URLQueryItem(name: "view", value: "mTeam"),
            URLQueryItem(name: "view", value: "mSettings")
        ]
        request(urlComponents.url, decode: { (json) -> League? in
            guard let league = json as? League else { return  nil }
            return league
        }) { (result) in
            switch result {
            case .success(let league):
                completion(league, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    func saveLeague(leagueId: Int32, completion: ((LeagueEntity?, Error?) -> Void)? = nil) {
        Networking.shared.getLeague(leagueId: leagueId) { (league, error) in
            guard var league = league else {
                completion?(nil, error)
                return
            }
            
            if let teamId = CookieManager.shared.swid,
                let primaryTeam = league.teams?.first(where: { $0.owners?.first == teamId }) {
                league.primaryTeamId = primaryTeam.id
            }
            
            let result = DataController.shared.viewContext.saveLeague(league)
            completion?(result.league, result.error)
        }
    }
    
//    func getTeam(leagueId: String, teamId: String, completion: @escaping (Team?, Error?) -> Void) {
//        guard var urlComponents = URLComponents(string: "\(baseURL)\(leagueId)") else { return }
//        urlComponents.queryItems = [
//            URLQueryItem(name: "view", value: "mTeam"),
//            URLQueryItem(name: "view", value: "mSettings")
//        ]
//
//        request(urlComponents.url, decode: { (json) -> League? in
//            guard let league = json as? League else { return  nil }
//            return league
//        }) { (result) in
//            switch result {
//            case .success(let league):
//                guard let team = league.teams?.first(where: { $0.owners?.first == teamId }) else {
//                    completion(nil, NetworkError.teamNotAvailable)
//                    return
//                }
//                completion(team, nil)
//                break
//            case .failure(let error):
//                completion(nil, error)
//                break
//            }
//        }
//    }
    
    func getMatchup(league: LeagueEntity, completion: @escaping (Schedule?, Error?) -> Void) {
        guard var urlComponents = URLComponents(string: "\(baseURL)\(league.id)") else { return }
        urlComponents.queryItems = [
            URLQueryItem(name: "view", value: "mRoster"),
            URLQueryItem(name: "view", value: "mMatchup"),
            URLQueryItem(name: "view", value: "mMatchupScore"),
            URLQueryItem(name: "scoringPeriodId", value: "\(league.scoringPeriodId)")
        ]
                
        request(urlComponents.url, decode: { (json) -> Matchup? in
            guard let matchup = json as? Matchup else { return  nil }
            return matchup
        }) { (result) in
            switch result {
            case .success(let matchup):
                guard let schedules = matchup.schedule,
                    let schedule = schedules.first(where: { $0.matchupPeriodId == Int(league.scoringPeriodId) && ($0.away?.teamId == Int(league.primaryTeamId) || $0.home?.teamId == Int(league.primaryTeamId))}) else {
                    completion(nil, NetworkError.scheduleNotAvailable)
                    return
                }
                completion(schedule, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
}

enum NetworkResult<T, U> where U: Error  {
    case success(T)
    case failure(U)
}

enum NetworkError: Error, LocalizedError {
    case noInternet
    case requestFailed
    case jsonConversionFailure
    case invalidData
    case authenticationFailed
    case responseUnsuccessful
    case jsonParsingFailure
    case teamNotAvailable /// FIXME: Move to models
    case scheduleNotAvailable
    
    var errorDescription: String? {
        switch self {
        case .noInternet: return "No Internet Connection"
        case .requestFailed: return "Request Failed"
        case .invalidData: return "Invalid Data"
        case .authenticationFailed: return "You need to log in."
        case .responseUnsuccessful: return "Response Unsuccessful"
        case .jsonParsingFailure: return "JSON Parsing Failure"
        case .jsonConversionFailure: return "JSON Conversion Failure"
        case .teamNotAvailable: return "Team not available. Check login."
        case .scheduleNotAvailable: return "Schedule not available."
        }
    }
}
