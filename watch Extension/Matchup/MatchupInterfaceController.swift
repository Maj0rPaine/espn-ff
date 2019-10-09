//
//  MatchupInterfaceController.swift
//  watch Extension
//
//  Created by Chris Paine on 10/7/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import WatchKit
import Foundation

class MatchupInterfaceController: WKInterfaceController {
    @IBOutlet weak var matchupStatusLabel: WKInterfaceLabel!
    @IBOutlet weak var table: WKInterfaceTable!
    
    var network = Networking.shared
    
    var league: LeagueEntity?
    
    var teams: [MatchupTeam]? {
        didSet {
            guard let teams = teams, !teams.isEmpty else { return }
            renderRows(data: teams)
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
                
        if let league = context as? LeagueEntity {
            self.league = league
            setTitle(league.name)
        }
    }

    override func willActivate() {
        super.willActivate()
            
        if league != nil {
            fetchMatchup()
        }
    }

    func fetchMatchup() {
        guard let league = league else { return }
        network.getMatchup(league: league) { [weak self] (schedule, error) in
            if let awayTeam = schedule?.away,
                let homeTeam = schedule?.home {
                self?.teams = [awayTeam, homeTeam]
                self?.matchupStatusLabel.setText("Week \(schedule?.matchupPeriodId ?? 0)")
            }
        }
    }
    
    func renderRows(data: [MatchupTeam]) {
        self.table.setNumberOfRows(data.count, withRowType: "MatchupRow")
        
        for index in 0..<self.table.numberOfRows {
            guard let controller = self.table.rowController(at: index) as? MatchupRowController else { continue }
            controller.league = league
            controller.configure(with: data[index])
        }
    }
}