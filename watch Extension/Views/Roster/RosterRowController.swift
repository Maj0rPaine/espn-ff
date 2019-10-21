//
//  RosterRowController.swift
//  watch Extension
//
//  Created by Chris Paine on 10/10/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import WatchKit

class RosterRowController: NSObject {
    @IBOutlet weak var image: WKInterfaceImage!
    @IBOutlet weak var nameLabel: WKInterfaceLabel!
    @IBOutlet weak var scoreLabel: WKInterfaceLabel!
    @IBOutlet weak var statusLabel: WKInterfaceLabel!
    
    func configure(with playerEntry: PlayerPoolEntry) {
        nameLabel.setText(playerEntry.player?.shortName)
        scoreLabel.setText(String(format: "%.1f", playerEntry.appliedStatTotal ?? 0.0))
        
        guard let status = playerEntry.player?.injuryStatus else { return }
        
        if status == .out {
            image.setImage(#imageLiteral(resourceName: "player-inactive-icon"))
            statusLabel.setText(status.code)
            statusLabel.setTextColor(.red)
            statusLabel.setHidden(false)
            scoreLabel.setHidden(true)
        }
    }
}
