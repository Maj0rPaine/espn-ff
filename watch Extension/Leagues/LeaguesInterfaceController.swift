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

class LeaguesInterfaceController: WKInterfaceController {
    @IBOutlet weak var statusLabel: WKInterfaceLabel!
    @IBOutlet weak var table: WKInterfaceTable!
    
    var connectivityHandler = WatchSessionManager.shared
    
    var cookieManager = CookieManager.shared
    
    var network = Networking.shared
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(fetchLeagues), name: Notification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
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
    
    func renderRows(data: [LeagueEntity]) {
        self.table.setNumberOfRows(data.count, withRowType: "LeagueRow")
        
        for index in 0..<self.table.numberOfRows {
            guard let controller = self.table.rowController(at: index) as? LeagueRowController else { continue }
            controller.leagueLabel.setText(data[index].name)
        }
    }
    
    @objc func fetchLeagues() {
        self.leagues = dataController.viewContext.fetchLeagues()
    }
}

extension LeaguesInterfaceController: WatchSessionManagerWatchOSDelegate {
    func messageReceived(tuple: MessageReceived) {
        guard let jsonString = tuple.message["configuration"] as? String,
            let configuration = Configuration.decoded(jsonString: jsonString) else { return }
        configuration.saveCookies(cookieManager: cookieManager)
        
        dataController.viewContext.deleteLeagues()
                
        for id in configuration.leagueIds {
            network.saveLeague(leagueId: id)
        }
    }
}
