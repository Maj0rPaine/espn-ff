//
//  Networking.swift
//  espn-ff
//
//  Created by Chris Paine on 10/2/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import Foundation
import UIKit

enum HTTPMethod: String {
    case get = "GET"
}

struct HTTPHeader {
    let field: String
    let value: String
}

class NetworkRequest {
    static let defaultPath = "apis/v3/games/ffl/seasons/2019/segments/0/leagues/"
    
    let method: HTTPMethod
    let path: String
    var queryItems: [URLQueryItem]?
    var headers: [HTTPHeader]?
    var body: Data?

    init(method: HTTPMethod = .get, path: String = NetworkRequest.defaultPath, queryItems: [URLQueryItem]? = nil) {
        self.method = method
        self.path = path
        self.queryItems = queryItems
    }

    init<Body: Encodable>(method: HTTPMethod, path: String, body: Body) throws {
        self.method = method
        self.path = path
        self.body = try JSONEncoder().encode(body)
    }
}

struct NetworkResponse<Body> {
    let statusCode: Int
    let body: Body
}
 
extension NetworkResponse {
    func verifyStatusCode() -> NetworkError? {
        switch statusCode {
        case 400: return .badRequest
        case 401: return .authenticationFailed
        case 404: return .notFound
        default: return nil
        }
    }
}

extension NetworkResponse where Body == Data? {
    func decode<BodyType: Decodable>(to type: BodyType.Type) throws -> NetworkResponse<BodyType> {
        guard let data = body else {
            throw NetworkError.invalidData
        }
        
        let decodedJSON = try JSONDecoder().decode(BodyType.self, from: data)
        return NetworkResponse<BodyType>(statusCode: self.statusCode, body: decodedJSON)
    }
}

enum NetworkResult<Body> {
    case success(NetworkResponse<Body>)
    case failure(NetworkError)
}

struct Networking {
    typealias NetworkCompletion = (NetworkResult<Data?>) -> Void
            
    private var baseURL = URL(string: "https://fantasy.espn.com")!

    private var session = URLSession.shared
    
    init(url: URL) {
        self.baseURL = url
    }
    
    init(configuration: URLSessionConfiguration = .default) {
        session = URLSession(configuration: configuration)
    }
    
    func perform(_ request: NetworkRequest, _ completion: @escaping NetworkCompletion) {
        var urlComponents = URLComponents()
        urlComponents.scheme = baseURL.scheme
        urlComponents.host = baseURL.host
        urlComponents.path = baseURL.path
        urlComponents.queryItems = request.queryItems

        guard let url = urlComponents.url?.appendingPathComponent(request.path) else {
            completion(.failure(.invalidURL)); return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body

        request.headers?.forEach { urlRequest.addValue($0.value, forHTTPHeaderField: $0.field) }
        
        print("**************************************************")
        print("Network Request:")
        print(urlRequest.debugDescription)

        let task = session.dataTask(with: urlRequest) { (data, response, error) in
             if let error = error as NSError?, error.code == NSURLErrorNotConnectedToInternet {
                completion(.failure(.noInternet))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.requestFailed)); return
            }
            completion(.success(NetworkResponse<Data?>(statusCode: httpResponse.statusCode, body: data)))
        }
        task.resume()
    }
}

extension Networking {
    func getLeague(leagueId: Int32, completion: @escaping (League?, Error?) -> Void) {
        let request = NetworkRequest(
            path: "\(NetworkRequest.defaultPath)\(leagueId)",
            queryItems: [
                URLQueryItem(name: "view", value: "mTeam"),
                URLQueryItem(name: "view", value: "mSettings")
        ])

        perform(request) { (result) in
            switch result {
            case .success(let response):
                if let error = response.verifyStatusCode() {
                    completion(nil, error == .notFound ? NetworkError.leagueNotFound : error)
                }
                
                if let response = try? response.decode(to: League.self) {
                    completion(response.body, nil)
                } else {
                    completion(nil, NetworkError.jsonParsingFailure)
                }
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    func saveLeague(leagueId: Int32, completion: ((LeagueEntity?, Error?) -> Void)? = nil) {
        getLeague(leagueId: leagueId) { (league, error) in
            guard var league = league else {
                completion?(nil, error)
                return
            }
            
            if let teamId = HTTPCookieStorage.shared.swid,
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
        let request = NetworkRequest(
            path: "\(NetworkRequest.defaultPath)\(league.id)",
            queryItems: [
                 URLQueryItem(name: "view", value: "mRoster"),
                 URLQueryItem(name: "view", value: "mMatchup"),
                 URLQueryItem(name: "view", value: "mMatchupScore"),
                 URLQueryItem(name: "scoringPeriodId", value: "\(league.scoringPeriodId)")
        ])
        
        perform(request) { (result) in
            switch result {
            case .success(let response):
                if let error = response.verifyStatusCode() {
                    completion(nil, error)
                }
                
                if let response = try? response.decode(to: Matchup.self) {
                    guard let schedules = response.body.schedule,
                        let schedule = schedules.first(where: { $0.matchupPeriodId == Int(league.scoringPeriodId) && ($0.away?.teamId == Int(league.primaryTeamId) || $0.home?.teamId == Int(league.primaryTeamId))}) else {
                        completion(nil, NetworkError.scheduleNotAvailable)
                        return
                    }
                    completion(schedule, nil)
                } else {
                    completion(nil, NetworkError.jsonParsingFailure)
                }
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    func getImage(completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = UIImage.imageCache.object(forKey: baseURL.absoluteString as AnyObject) as? UIImage {
            completion(cachedImage)
            return
        }
        
        let request = NetworkRequest(path: "")
        
        perform(request) { (result) in
            switch result {
            case .success(let response):
                if let _ = response.verifyStatusCode() {
                    completion(nil)
                }
                
                if let data = response.body,
                    let image = UIImage(data: data) {
                    image.cache(with: self.baseURL.absoluteString)
                    completion(image)
                } else {
                    completion(nil)
                }
            case .failure:
                completion(nil)
            }
        }
    }
}

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noInternet
    case requestFailed
    case jsonConversionFailure
    case invalidData
    case badRequest
    case authenticationFailed
    case notFound
    case jsonParsingFailure
    case leagueNotFound
    case teamNotAvailable /// FIXME: Move to models
    case scheduleNotAvailable
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .noInternet: return "No Internet Connection"
        case .requestFailed: return "Request Failed"
        case .invalidData: return "Invalid Data"
        case .badRequest: return "Bad Request"
        case .authenticationFailed: return "You need to log in with ESPN."
        case .notFound: return "Not Found."
        case .jsonParsingFailure: return "JSON Parsing Failure"
        case .jsonConversionFailure: return "JSON Conversion Failure"
        case .leagueNotFound: return "League not found. Check league ID."
        case .teamNotAvailable: return "Team not available. Check login."
        case .scheduleNotAvailable: return "Schedule not available."
        }
    }
}
