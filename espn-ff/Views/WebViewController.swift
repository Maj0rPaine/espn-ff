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
    
    let network = Networking.shared
    
    let cookieStorage = HTTPCookieStorage.shared

    let defaults = UserDefaults.standard
    
    let hasSeenESPNTutorial = "hasSeenESPNTutorial"
                
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.startAnimating()
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicatorView
    }()
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !defaults.bool(forKey: hasSeenESPNTutorial) {
            present(UIAlertController.createAlert(title: "Here's a tip!", message: "After logging in, you can save your league by selecting it.", okHandler: { (action) in
                self.defaults.set(true, forKey: self.hasSeenESPNTutorial)
            }), animated: true, completion: nil)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        cookieStorage.syncCookies(with:  webView.configuration.websiteDataStore.httpCookieStore)
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
        cookieStorage.syncCookies(with: webView.configuration.websiteDataStore.httpCookieStore) {
            guard let id = Int32(leagueId) else { return }
            
            self.network.saveLeague(leagueId: id) { [weak self] (league, error) in
                guard league != nil else {
                    if let error = error {
                       self?.present(UIAlertController.createErrorAlert(message: error.localizedDescription), animated: true, completion: nil)
                    }
                    return
                }
                
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

extension HTTPCookieStorage {
    func syncCookies(with wkCookieStore: WKHTTPCookieStore, completion: (() -> Void)? = nil) {
        if cookieValue(for: HTTPCookieStorage.SWID_COOKIE_NAME) != nil && cookieValue(for: HTTPCookieStorage.ESPN_COOKIE_NAME) != nil {
            completion?()
            return
        }
        
        wkCookieStore.getAllCookies { (cookies) in
            self.clearCookies()
            cookies.forEach { self.saveCookie($0) }
            completion?()
        }
    }
}
