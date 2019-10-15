//
//  LeagueViewController.swift
//  espn-ff
//
//  Created by Chris Paine on 10/1/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import UIKit
import WatchConnectivity
import CoreData

class LeagueViewController: UIViewController {
    var connectivityHandler = WatchSessionManager.shared
    
    var cookieStorage = HTTPCookieStorage.shared
        
    var dataController = DataController.shared
        
    var leagueTableView: LeagueTableView!
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.startAnimating()
        return activityIndicator
    }()
    
    override func loadView() {
        leagueTableView = LeagueTableView(frame: .zero, style: .insetGrouped)
        leagueTableView.delegate = self
        view = leagueTableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Leagues"
                
        connectivityHandler.iOSDelegate = self
        connectivityHandler.startSession()
        
        NotificationCenter.default.addObserver(self, selector: #selector(observeLeagueChanges(_:)), name: Notification.Name.NSManagedObjectContextDidSave, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func observeLeagueChanges(_ notification: Notification) {
        sendConfiguration()
    }
    
    // TODO: Check league completeness before sending configuration to watch
    func sendConfiguration() {
        guard connectivityHandler.validSession != nil,
            let cookies = cookieStorage.savedCookies,
            let entities = leagueTableView.fetchedResultsController.fetchedObjects,
            let stringData = Configuration(cookies: cookies, leagueIds: entities.map { $0.id }).encoded() else { return }
        print("Phone sending configuration")
        let message = [
            "request" : RequestType.setupConfiguration.rawValue as AnyObject,
            "configuration" : stringData as AnyObject
        ]
        connectivityHandler.sendMessage(message: message) { (error) in
            print("Error sending message: \(error)")
        }
    }
}

extension LeagueViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        present(UIAlertController.createAlert(title: "Wanna see this week's matchup?", message: "Open the companion app on your watch to view your matchup for this week."), animated: true, completion: nil)
    }
}

extension LeagueViewController: WatchSessionManageriOSDelegate {
    func messageReceived(tuple: MessageReceived) {
        switch tuple.message["request"] as! RequestType.RawValue {
        case RequestType.configuration.rawValue:
            print("Phone received configuration request")
            sendConfiguration()
            break
        default:
            break
        }
    }
}
