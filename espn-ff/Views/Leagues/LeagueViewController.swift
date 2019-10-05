//
//  LeagueViewController.swift
//  espn-ff
//
//  Created by Chris Paine on 10/1/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import UIKit

class LeagueViewController: UIViewController {
    @IBOutlet weak var signInButton: UIBarButtonItem!
    
    @IBOutlet weak var addLeagueButton: UIBarButtonItem!
    
    var cookieManager: CookieManager!
    
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
        
        addLeagueButton.isEnabled = false
        
        cookieManager = CookieManager { containsAuthCookie in
            self.signInButton.title = containsAuthCookie ? "Logged In" : "Log In"
            self.addLeagueButton.isEnabled = containsAuthCookie
        }
    }
    
    @IBAction func presentWebView(_ sender: Any) {
        present(UINavigationController(rootViewController: WebViewController(cookieManager: cookieManager)), animated: true, completion: nil)
    }
    
    @IBAction func pushNewLeagueController() {
        navigationController?.pushViewController(NewLeagueController(style: .grouped), animated: true)
    }
}

extension LeagueViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? LeagueCell,
            let leagueId = cell.leagueId,
            let teamId = cookieManager.swid else { return }
                
        Networking.instance.getTeam(leagueId: leagueId, teamId: teamId) { [weak self] (team, error) in
            guard let team = team else {
                if error != nil {
                    self?.cookieManager.clearCookies()
                    self?.present(UIAlertController.createErrorAlert(message: error?.localizedDescription), animated: true, completion: nil)
                }
                return
            }
            let teamDetailsViewController = TeamDetailsViewController(team: team)
            teamDetailsViewController.title = cell.textLabel?.text
            self?.navigationController?.pushViewController(teamDetailsViewController, animated: true)
        }
    }
}
