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
    var webView: WKWebView!
    
    var cookieManager: CookieManager!
            
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.startAnimating()
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicatorView
    }()
    
    convenience init(cookieManager: CookieManager) {
        self.init()
        self.cookieManager = cookieManager
    }
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        webView.addSubview(activityIndicator)
        webView.addConstraints([
            activityIndicator.centerYAnchor.constraint(equalTo: webView.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: webView.centerXAnchor)
        ])
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissController))
        
        guard let url = URL(string:"https://www.espn.com/fantasy/") else {
            dismissController()
            return
        }
        webView.load(URLRequest(url: url))
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { (cookies) in
            for cookie in cookies {
                self.cookieManager.saveCookie(cookie)
            }
        }
    }
    
    func confirmSaveLeague(_ leagueId: String) {
        let actionSheet = UIAlertController(title: "League ID: \(leagueId)", message: "Do you want to save this league?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Save", style: .default, handler: { (action) in
            self.saveLeague(leagueId)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
    
    func saveLeague(_ leagueId: String) {
        Networking.shared.saveLeague(leagueId: leagueId) { [weak self] (league, error) in
            guard error == nil else {
                self?.present(UIAlertController.createErrorAlert(message: error?.localizedDescription), animated: true, completion: nil)
                return
            }

            DispatchQueue.main.async {
                self?.present(UIAlertController.createAlert(title: "Success", message: "You saved a new league."), animated: true, completion: nil)
            }
        }
    }
    
    @objc func dismissController() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
                
        if let leagueId = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.first(where: { $0.name.contains("leagueId")})?.value {
            confirmSaveLeague(leagueId)
            decisionHandler(.cancel)
            return
        }
        
        //print(url)
        decisionHandler(.allow)
    }
}
