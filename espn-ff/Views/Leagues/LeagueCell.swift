//
//  LeagueCell.swift
//  espn-ff
//
//  Created by Chris Paine on 10/2/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import UIKit

class LeagueCell: UITableViewCell {
    var leagueId: String?
    
    convenience init(entity: LeagueEntity) {
        self.init(style: .default, reuseIdentifier: nil)
        self.leagueId = "\(entity.id)"
        textLabel?.text = entity.name
        accessoryType = .disclosureIndicator
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
