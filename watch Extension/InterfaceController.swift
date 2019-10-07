//
//  InterfaceController.swift
//  watch Extension
//
//  Created by Chris Paine on 10/3/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity
import CoreData

class InterfaceController: WKInterfaceController {
    @IBOutlet weak var statusLabel: WKInterfaceLabel!
    @IBOutlet weak var table: WKInterfaceTable!
    
    var connectivityHandler = WatchSessionManager.shared

    var session : WCSession?
    
    var cookieManager: CookieManager!
    
    var needsCookies = true
    
    var leagues: [LeagueEntity]? {
        didSet {
            guard let leagues = leagues, !leagues.isEmpty else { return }
            statusLabel.setText("Select League")
            renderRows(data: leagues)
        }
    }

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        connectivityHandler.startSession()
        connectivityHandler.watchOSDelegate = self
        
        cookieManager = CookieManager { containsAuthCookie in
            print("Contains auth cookie: \(containsAuthCookie)")
    
            if containsAuthCookie {
                self.needsCookies = false
                self.leagues = DataController.shared.viewContext.fetchLeagues()
            }
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func renderRows(data: [LeagueEntity]) {
        self.table.setNumberOfRows(data.count, withRowType: "LeagueRow")
        
        for index in 0..<self.table.numberOfRows {
            guard let controller = self.table.rowController(at: index) as? LeagueRowController else { continue }
            controller.leagueLabel.setText(data[index].name)
        }
    }
}

extension InterfaceController: WatchSessionManagerWatchOSDelegate {
    func messageReceived(tuple: MessageReceived) {
        guard let jsonString = tuple.message["configuration"] as? String,
            let data = jsonString.data(using: .utf8),
            let configuration = try? JSONDecoder().decode(Configuration.self, from: data) else { return }
        print(configuration)
        configuration.saveCookies(cookieManager: cookieManager)
        
        DataController.shared.viewContext.deleteLeagues()
        
        self.leagues = DataController.shared.viewContext.createLeagues(leagues: configuration.leagues)
    }
}
