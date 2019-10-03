//
//  CookieManager.swift
//  espn-ff
//
//  Created by Chris Paine on 10/1/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import Foundation

import WebKit

class CookieManager {
    var defaults = UserDefaults.standard
    
    var cookieStorage = HTTPCookieStorage.shared
    
    var cookieStore = WKWebsiteDataStore.default().httpCookieStore
    
    var foundCookies: ((Bool) -> Void)?
    
    let ESPN_COOKIE_NAME = "espn_s2"
    
    let SWID_COOKIE_NAME = "SWID"
    
    var espnCookie: String? {
        return defaults.string(forKey: ESPN_COOKIE_NAME)
    }
    
    var swidCookie: String? {
        return defaults.string(forKey: SWID_COOKIE_NAME)
    }
    
    init(_ foundCookies: ((Bool) -> Void)? = nil) {
        self.foundCookies = foundCookies
        checkCookies()
    }
    
    func saveCookie(_ cookie: HTTPCookie) {
        guard cookie.name == ESPN_COOKIE_NAME || cookie.name == SWID_COOKIE_NAME else { return }
        cookieStorage.setCookie(cookie)
        defaults.set(cookie.value, forKey: cookie.name)
        print("Set \(cookie.name) cookie")
        checkCookies()
    }
    
    func checkCookies() {
        foundCookies?(espnCookie != nil && swidCookie != nil)
    }
    
    func fetchCookies() {
        cookieStore.getAllCookies { cookies in
            for cookie in cookies {
                self.saveCookie(cookie)
            }
        }
    }
    
    func clearCookies() {
        defaults.removeObject(forKey: ESPN_COOKIE_NAME)
        checkCookies()
    }
}
