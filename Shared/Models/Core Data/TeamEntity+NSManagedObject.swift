//
//  TeamEntity+NSManagedObject.swift
//  espn-ff
//
//  Created by Chris Paine on 10/7/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import Foundation
import CoreData

extension TeamEntity {
    convenience init(team: Team, context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = Int16(team.id ?? 0)
        self.abbreviation = team.abbrev
        self.fullName = team.description
    }
}
