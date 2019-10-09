//
//  MatchupRowController.swift
//  watch Extension
//
//  Created by Chris Paine on 10/8/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import WatchKit

class MatchupRowController: NSObject {
    @IBOutlet weak var teamImage: WKInterfaceImage!
    @IBOutlet weak var teamAbbreviationLabel: WKInterfaceLabel!
    @IBOutlet weak var teamScoreLabel: WKInterfaceLabel!
    
    var dataController = DataController.shared
    
    var league: LeagueEntity?
    
    // TODO: Investigate team logos
    func configure(with team: MatchupTeam) {
        if let leagueId = league?.id,
            let teamId = team.teamId,
            let team = dataController.viewContext.fetchTeam(for: leagueId, with: Int16(teamId)) {
            
            if let logo = team.logo,
                let image = UIImage.load(from: logo) {
                teamImage.setImage(image)
            }
            
            teamAbbreviationLabel.setText(team.abbreviation)
        }
        
        teamScoreLabel.setText(String(format: "%.1f", team.totalPoints ?? 0.0))
    }
}
