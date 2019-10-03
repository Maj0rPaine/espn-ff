//
//  Extensions.swift
//  espn-ff
//
//  Created by Chris Paine on 10/2/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import UIKit

extension UIAlertController {
    static func createAlert(title: String?, message: String?, okHandler: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: okHandler))
        return alert
    }
    
    static func createErrorAlert(message: String?, okHandler: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        return UIAlertController.createAlert(title: "Oops", message: message, okHandler: okHandler)
    }
}
