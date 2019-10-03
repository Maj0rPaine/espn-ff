//
//  TeamDetailsViewController.swift
//  espn-ff
//
//  Created by Chris Paine on 10/2/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import UIKit

class TeamDetailsViewController: UIViewController {
    var team: Team!
    
    convenience init(team: Team) {
        self.init()
        self.team = team
    }
    
    lazy var stackView: UIStackView = {
        let imageView = UIImageView()
        
        let nameLabel = UILabel()
        nameLabel.text = team.description
        
        let stackView = UIStackView(arrangedSubviews: [imageView, nameLabel])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(stackView)
        view.addConstraints([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
}
