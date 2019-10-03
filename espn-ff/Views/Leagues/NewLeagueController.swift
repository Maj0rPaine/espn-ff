//
//  NewLeagueController.swift
//  espn-ff
//
//  Created by Chris Paine on 10/2/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import UIKit

class NewLeagueController: UITableViewController {
    let leagueCell = LeagueCell()
    
    override init(style: UITableView.Style) {
        super.init(style: style)
        title = "Add League"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveNewLeague))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return leagueCell
    }
    
    @objc func saveNewLeague() {
        guard let id = leagueCell.leagueId else { return }
                
        Networking.instance.saveLeague(leagueId: id) { [weak self] (league, error) in
            guard error == nil else {
                self?.present(UIAlertController.createErrorAlert(message: error?.localizedDescription), animated: true, completion: nil)
                return
            }
            
            DispatchQueue.main.async {
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
}
