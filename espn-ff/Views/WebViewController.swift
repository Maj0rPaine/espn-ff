//
//  WebViewController.swift
//  espn-ff
//
//  Created by Chris Paine on 10/1/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    var webView = WKWebView()
    
    override func loadView() {
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = URL(string:"https://www.espn.com/fantasy/") else {
            dismiss(animated: true, completion: nil)
            return
        }
        webView.load(URLRequest(url: url))
    }
}
