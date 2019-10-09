//
//  CookieManager.swift
//  espn-ff
//
//  Created by Chris Paine on 10/1/19.
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

class CookieManager {
    static let shared = CookieManager()
    
    var containsAuthCookie: ((Bool) -> Void)?
    
    let ESPN_COOKIE_NAME = "espn_s2"
    
    let SWID_COOKIE_NAME = "SWID"
    
    var cookieStorage: HTTPCookieStorage {
        return HTTPCookieStorage.shared
    }
    
    var espn: String? {
        guard let cookie = cookieStorage.cookies?.first(where: { $0.name.contains(ESPN_COOKIE_NAME) }) else { return nil }
        return cookie.value
    }
    
    var swid: String? {
        guard let cookie = cookieStorage.cookies?.first(where: { $0.name.contains(SWID_COOKIE_NAME) }) else { return nil }
        return cookie.value
    }
    
    func saveCookie(_ cookie: HTTPCookie) {
        guard cookie.name == ESPN_COOKIE_NAME || cookie.name == SWID_COOKIE_NAME else { return }
        cookieStorage.setCookie(cookie)
        print("Set \(cookie.name) cookie")
        checkCookies()
    }
    
    func checkCookies() {
        guard let cookies = cookieStorage.cookies else {
            containsAuthCookie?(false)
            return
        }
        containsAuthCookie?(cookies.contains { $0.name.contains(ESPN_COOKIE_NAME)})
    }
    
    func clearCookies() {
        cookieStorage.cookies?.forEach(cookieStorage.deleteCookie(_:))
    }
    
    func savedCookies() -> [Cookie]? {
        guard let cookies = cookieStorage.cookies else { return nil }
        return cookies.map { Cookie($0) }
    }
}
