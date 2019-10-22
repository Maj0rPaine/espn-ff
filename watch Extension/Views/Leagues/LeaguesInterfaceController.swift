//
//  LeaguesInterfaceController.swift
//  watch Extension
//
//  Created by Chris Paine on 10/3/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity
import CoreData

// TODO: Set favorite league on select
// TODO: League paging
class LeaguesInterfaceController: WKInterfaceController {
    @IBOutlet weak var statusLabel: WKInterfaceLabel!
    @IBOutlet weak var table: WKInterfaceTable!
    
    var connectivityHandler = WatchSessionManager.shared
    
    var cookieStorage = HTTPCookieStorage.shared
    
    var network = Networking()
    
    var dataController = DataController.shared

    var session : WCSession?
            
    var leagues: [LeagueEntity]? {
        didSet {
            guard let leagues = leagues, !leagues.isEmpty else {
                statusLabel.setText("Open iPhone app to set up leagues.")
                renderRows(data: [])
                return
            }
            statusLabel.setText("Select League")
            renderRows(data: leagues)
        }
    }

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        NotificationCenter.default.addObserver(self, selector: #selector(observeLeagueChanges(_:)), name: Notification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
    }
    
    override func willActivate() {
        super.willActivate()
        
        connectivityHandler.startSession()
        connectivityHandler.watchOSDelegate = self
        
        fetchLeagues()
    }
    
    override func didDeactivate() {
        NotificationCenter.default.removeObserver(self)
        
        super.didDeactivate()
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        guard let leagues = leagues else { return }
        let selectedLeague = leagues[rowIndex]
        pushController(withName: "MatchupController", context: selectedLeague)
    }
    
    @objc func observeLeagueChanges(_ notification: Notification) {
        guard let keys = notification.userInfo?.keys else { return }
        
        if keys.contains(NSInsertedObjectsKey) {
            fetchLeagues()
        }
        
        if keys.contains(NSDeletedObjectsKey) {
            leagues = nil
        }
    }
    
    func fetchLeagues() {
        leagues = dataController.viewContext.fetchLeagues()
    }
    
    func requestConfiguration() {
        print("Watch requesting configuration")
        let data = ["request" : RequestType.configuration.rawValue as AnyObject]
        connectivityHandler.sendMessage(message: data) { (error) in
            print("Error sending message: \(error)")
        }
    }
    
    func renderRows(data: [LeagueEntity]) {
        self.table.setNumberOfRows(data.count, withRowType: "LeagueRow")
        
        for index in 0..<self.table.numberOfRows {
            guard let controller = self.table.rowController(at: index) as? LeagueRowController else { continue }
            controller.leagueLabel.setText(data[index].name)
        }
    }
}

extension LeaguesInterfaceController: WatchSessionManagerWatchOSDelegate {
    func messageReceived(tuple: MessageReceived) {
        switch tuple.message["request"] as! RequestType.RawValue {
        case RequestType.setupConfiguration.rawValue:
            print("Watch received configuration")
            guard let jsonString = tuple.message["configuration"] as? String,
                let configuration = Configuration.decoded(jsonString: jsonString) else { return }
            configuration.saveCookies(cookieManager: cookieStorage)
            
            dataController.viewContext.deleteLeagues()
                    
            for id in configuration.leagueIds {
                network.saveLeague(leagueId: id)
            }
            
            // TODO: Schedule background tasks on initial setup
        default:
            break
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            if let leagues = leagues, leagues.isEmpty {
                requestConfiguration()
            }
        }
    }
}
