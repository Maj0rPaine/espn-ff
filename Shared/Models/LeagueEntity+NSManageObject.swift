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
        self.id = "\(league.leagueId ?? 0)"
        self.name = league.name
        
        context.saveChanges()
    }
}
