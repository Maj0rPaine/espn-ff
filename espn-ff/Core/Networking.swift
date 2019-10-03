//
//  Networking.swift
//  espn-ff
//
//  Created by Chris Paine on 10/2/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import Foundation

enum NetworkResult<T, U> where U: Error  {
    case success(T)
    case failure(U)
}

enum NetworkError: Error {
    case noInternet
    case requestFailed
    case jsonConversionFailure
    case invalidData
    case responseUnsuccessful
    case jsonParsingFailure
    
    var localizedDescription: String {
        switch self {
        case .noInternet: return "No Internet Connection"
        case .requestFailed: return "Request Failed"
        case .invalidData: return "Invalid Data"
        case .responseUnsuccessful: return "Response Unsuccessful"
        case .jsonParsingFailure: return "JSON Parsing Failure"
        case .jsonConversionFailure: return "JSON Conversion Failure"
        }
    }
}

class Networking {
    typealias JSONTaskCompletionHandler = (Decodable?, NetworkError?) -> Void
    
    static let instance = Networking()
    
    let baseURL = "https://fantasy.espn.com/apis/v3/games/ffl/seasons/2019/segments/0/leagues/"

    let session: URLSession = URLSession(configuration: .default)

    var dataTask: URLSessionDataTask?
    
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
                #if DEBUG
                print(error)
                #endif
                completion(nil, .noInternet)
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(nil, .requestFailed)
                return
            }
            
            // TODO: Handle status codes
            if response.statusCode == 200 {
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
            } else {
                completion(nil, .responseUnsuccessful)
            }
        }
    }
}

extension Networking {
    func getLeague(leagueId: String, completion: @escaping (League?, Error?) -> Void) {
        request(URL(string: "\(baseURL)\(leagueId)"), decode: { (json) -> League? in
            guard let league = json as? League else { return  nil }
            return league
        }) { (result) in
            switch result {
            case .success(let league):
                completion(league, nil)
                break
            case .failure(let error):
                completion(nil, error)
                break
            }
        }
    }
    
    func getTeam(leagueId: String, teamId: String, completion: @escaping (Team?, Error?) -> Void) {
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
                let team = league.teams?.first(where: { $0.owners?.first == teamId })
                completion(team, nil)
                break
            case .failure(let error):
                completion(nil, error)
                break
            }
        }
    }
}
