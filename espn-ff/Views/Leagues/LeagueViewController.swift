//
//  LeagueViewController.swift
//  espn-ff
//
//  Created by Chris Paine on 10/1/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import UIKit
import WatchConnectivity

class LeagueViewController: UIViewController {
    @IBOutlet weak var signInButton: UIBarButtonItem!
        
    var connectivityHandler = WatchSessionManager.shared
    
    var cookieManager = CookieManager.shared
    
    var webViewController: WebViewController!
    
    var leagueTableView: LeagueTableView!
    
    override func loadView() {
        leagueTableView = LeagueTableView(frame: .zero, style: .grouped)
        leagueTableView.delegate = self
        view = leagueTableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Leagues"
                
        cookieManager.containsAuthCookie = { containsAuthCookie in
            self.signInButton.title = containsAuthCookie ? "Logged In" : "Log In"
        }
        
        cookieManager.checkCookies()
        
        NotificationCenter.default.addObserver(self, selector: #selector(sendMessage), name: Notification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func presentWebView(_ sender: Any) {
        present(UINavigationController(rootViewController: WebViewController(cookieManager: cookieManager)), animated: true, completion: nil)
    }
    
    @objc func sendMessage() {
        guard connectivityHandler.validSession != nil,
            let cookies = cookieManager.savedCookies(),
            let entities = leagueTableView.fetchedResultsController.fetchedObjects,
            let stringData = Configuration(cookies: cookies, leagueIds: entities.map { "\($0.id)" }).encoded() else { return }
        
        let message = ["configuration" : stringData]
        connectivityHandler.sendMessage(message: message as [String : AnyObject], replyHandler: { (response) in
            print("Reply: \(response)")
        }) { (error) in
            print("Error sending message: \(error)")
        }
    }
}

extension LeagueViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let cell = tableView.cellForRow(at: indexPath) as? LeagueCell,
//            let leagueId = cell.leagueId,
//            let teamId = cookieManager.swid else { return }
//
//        Networking.shared.getTeam(leagueId: leagueId, teamId: teamId) { [weak self] (team, error) in
//            guard let team = team else {
//                if error != nil {
//                    self?.cookieManager.clearCookies()
//                    self?.present(UIAlertController.createErrorAlert(message: error?.localizedDescription), animated: true, completion: nil)
//                }
//                return
//            }
//            let teamDetailsViewController = TeamDetailsViewController(team: team)
//            teamDetailsViewController.title = cell.textLabel?.text
//            self?.navigationController?.pushViewController(teamDetailsViewController, animated: true)
//        }
    }
}
