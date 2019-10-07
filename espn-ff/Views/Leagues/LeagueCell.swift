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
    
    var textField: UITextField!
    
    convenience init() {
        self.init(style: .default, reuseIdentifier: nil)
        textField = UITextField()
        textField?.placeholder = "Enter League ID"
        textField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textField)
        contentView.addConstraints([
            textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            textField.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8),
            textField.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8)
        ])
        selectionStyle = .none
    }
    
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
    
    @objc func textFieldChanged(_ sender: UITextField) {
        leagueId = sender.text
        print("League ID: \(leagueId)")
    }
}
