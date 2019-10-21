//
//  RosterInterfaceController.swift
//  watch Extension
//
//  Created by Chris Paine on 10/10/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import WatchKit
import Foundation


class RosterInterfaceController: WKInterfaceController {
    @IBOutlet weak var table: WKInterfaceTable!
    
    var team: MatchupTeam? {
        didSet {
            guard let playerEntries = team?.rosterForCurrentScoringPeriod?.sortedEntries else { return }
            renderRows(data: playerEntries)
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if let team = context as? MatchupTeam {
            self.team = team
        }
    }

    func renderRows(data: [Entry]) {
        self.table.setNumberOfRows(data.count, withRowType: "RosterRow")

        for index in 0..<self.table.numberOfRows {
            guard let controller = self.table.rowController(at: index) as? RosterRowController,
                let playerEntry = data[index].playerPoolEntry else { continue }
            controller.configure(with: playerEntry)
        }
    }
}
