//
//  Configuration.swift
//  espn-ff
//
//  Created by Chris Paine on 10/6/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import Foundation

struct Configuration: Codable {
    var cookies: [Cookie]
    var leagueIds: [Int32]
}

extension Configuration {
    func encoded() -> String? {
        guard let json = try? JSONEncoder().encode(self),
            let jsonString = String(data: json, encoding: String.Encoding.utf8) else { return nil }
        return jsonString
    }
    
    static func decoded(jsonString: String) -> Configuration? {
        guard let data = jsonString.data(using: .utf8),
            let configuration = try? JSONDecoder().decode(Configuration.self, from: data) else { return nil }
        print(configuration)
        return configuration
    }
    
    func saveCookies(cookieManager: HTTPCookieStorage) {
        for cookie in self.cookies {
            if let httpCookie = cookie.createHTTPCookie() {
                cookieManager.saveCookie(httpCookie)
            }
        }
    }
}
