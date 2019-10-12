//
//  Extensions.swift
//  espn-ff
//
//  Created by Chris Paine on 10/8/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import UIKit

extension UIImage {
    static func load(from url: String?) -> UIImage? {
        guard let urlString = url,
            let url = URL(string: urlString),
            let imageData = try? Data(contentsOf: url),
            let image = UIImage(data: imageData) else { return nil }
        return image
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
