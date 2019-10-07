//
//  LeagueEntity+NSManageObject.swift
//  espn-ff
//
//  Created by Chris Paine on 10/6/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import Foundation
import CoreData

extension LeagueEntity {
    convenience init(league: League, context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = Int32(league.leagueId ?? 0)
        self.name = league.name
        
        if let leagueTeams = league.teams {
            self.teams = NSSet(array: leagueTeams.map { TeamEntity(team: $0, context: context) })
        }
                
        context.saveChanges()
    }
}
