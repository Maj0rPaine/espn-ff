//
//  Cookie.swift
//  espn-ff
//
//  Created by Chris Paine on 10/12/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import Foundation

struct Cookie: Codable {
    var domain: String
    var path: String
    var name: String
    var value: String
    var isSecure: Bool
    var expiresDate: Date?
    
    init(_ cookie: HTTPCookie) {
        self.domain = cookie.domain
        self.path = cookie.path
        self.name = cookie.name
        self.value = cookie.value
        self.isSecure = cookie.isSecure
        self.expiresDate = cookie.expiresDate
    }
    
    func createHTTPCookie() -> HTTPCookie? {
        let cookieProps: [HTTPCookiePropertyKey : Any] = [
            HTTPCookiePropertyKey.domain: domain,
            HTTPCookiePropertyKey.path: path,
            HTTPCookiePropertyKey.name: name,
            HTTPCookiePropertyKey.value: value,
            HTTPCookiePropertyKey.secure: isSecure,
            HTTPCookiePropertyKey.expires: expiresDate!
        ]
        return HTTPCookie(properties: cookieProps)
    }
}
