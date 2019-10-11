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
    var fullName: String {
        guard let location = location,
            let nickname = nickname else { return "" }
        return "\(location) \(nickname)"
    }
    
    convenience init(team: Team, context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = Int16(team.id ?? 0)
        self.abbreviation = team.abbrev
        self.location = team.location
        self.nickname = team.nickname
        self.logo = team.logo
        self.ownerId = team.owners?.first
    }
}
