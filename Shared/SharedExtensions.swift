//
//  Extensions.swift
//  espn-ff
//
//  Created by Chris Paine on 10/8/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import UIKit

extension UIImage {
    static let imageCache = NSCache<AnyObject, AnyObject>()
    
    func cache(with key: String) {
        UIImage.imageCache.setObject(self, forKey: key as AnyObject)
    }
}

extension HTTPCookieStorage {
    static let ESPN_COOKIE_NAME = "espn_s2"
    
    static let SWID_COOKIE_NAME = "SWID"
    
    var swid: String? {
        return cookieValue(for: HTTPCookieStorage.SWID_COOKIE_NAME)
    }
    
    var savedCookies: [Cookie]? {
        guard let cookies = cookies else { return nil }
        return cookies.map { Cookie($0) }
    }
    
    func cookieValue(for name: String) -> String? {
        guard let cookie = cookies?.first(where: { $0.name.contains(name) }) else { return nil }
        return cookie.value
    }
    
    func saveCookie(_ cookie: HTTPCookie) {
        guard cookie.name == HTTPCookieStorage.ESPN_COOKIE_NAME || cookie.name == HTTPCookieStorage.SWID_COOKIE_NAME else { return }
        setCookie(cookie)
        print("Set \(cookie.name) cookie")
    }
    
    func clearCookies() {
        cookies?.forEach(deleteCookie(_:))
    }
}

extension Date {
    func formattedLocalTime() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeStyle = .medium
        return formatter.string(from: self)
    }
}
