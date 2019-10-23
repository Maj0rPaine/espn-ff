//
//  EmptyLeagueView.swift
//  espn-ff
//
//  Created by Chris Paine on 10/13/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import UIKit

extension UILabel {
    convenience init(text: String, font: UIFont) {
        self.init(frame: .zero)
        self.text = text
        self.font = font
        self.numberOfLines = 0
        self.textAlignment = .center
    }
}

class EmptyView: UIView {
    lazy var stackView: UIStackView = {
        let titleLabel = UILabel(text: "No Leagues",
                                 font: UIFont.systemFont(ofSize: 24, weight: .semibold))

        let subtitleLabel = UILabel(text: "Start adding leagues to view \n weekly matchups on your watch.",
                                    font: UIFont.systemFont(ofSize: 18, weight: .light))
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(stackView)
        addConstraints([
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
