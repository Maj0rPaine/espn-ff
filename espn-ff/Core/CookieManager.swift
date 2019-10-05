//
//  CookieManager.swift
//  espn-ff
//
//  Created by Chris Paine on 10/1/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import Foundation

class CookieManager {
    var containsAuthCookie: ((Bool) -> Void)?
    
    static let sharedCookieStorage = HTTPCookieStorage.sharedCookieStorage(forGroupContainerIdentifier: "group.com.chrispaine.espn-ff")
    
    let ESPN_COOKIE_NAME = "espn_s2"
    
    let SWID_COOKIE_NAME = "SWID"
    
    var swid: String? {
        guard let cookie = CookieManager.sharedCookieStorage.cookies?.first(where: { $0.name.contains(SWID_COOKIE_NAME) }) else { return nil }
        return cookie.value
    }
    
    init(_ containsAuthCookie: ((Bool) -> Void)? = nil) {
        self.containsAuthCookie = containsAuthCookie
        checkCookies()
    }
    
    func saveCookie(_ cookie: HTTPCookie) {
        guard cookie.name == ESPN_COOKIE_NAME || cookie.name == SWID_COOKIE_NAME else { return }
        CookieManager.sharedCookieStorage.setCookie(cookie)
        print("Set \(cookie.name) cookie")
        checkCookies()
    }
    
    func checkCookies() {
        guard let cookies = CookieManager.sharedCookieStorage.cookies else {
            containsAuthCookie?(false)
            return
        }
        containsAuthCookie?(cookies.contains { $0.name.contains(ESPN_COOKIE_NAME)})
    }
    
    func clearCookies() {
        CookieManager.sharedCookieStorage.cookies?.forEach(CookieManager.sharedCookieStorage.deleteCookie(_:))
        checkCookies()
    }
}
