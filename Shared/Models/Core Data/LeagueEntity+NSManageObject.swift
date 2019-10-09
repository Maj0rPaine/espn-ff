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
        self.scoringPeriodId = Int16(league.scoringPeriodId ?? 0)
        self.name = league.name
        self.primaryTeamId = Int16(league.primaryTeamId ?? -1)
        
        if let leagueTeams = league.teams {
            self.teams = NSSet(array: leagueTeams.map { TeamEntity(team: $0, context: context) })
        }
                
        context.saveChanges()
    }
    
//    func primaryTeamLogoURL(context: NSManagedObjectContext) -> String? {
//        return context.fetchTeam(with: primaryTeamId)?.logo
//    }
//    
//    func primaryTeamName(context: NSManagedObjectContext) -> String? {
//        if let team = context.fetchTeam(with: primaryTeamId),
//            let location = team.location,
//            let nickname = team.nickname {
//            return "\(location) \(nickname)"
//        }
//        return nil
//    }
}
