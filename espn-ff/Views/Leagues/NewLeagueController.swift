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
        
        League.getLeague(leagueId: id) { (league, error) in
            guard let league = league else {
                if let error = error {
                    self.present(UIAlertController.createAlert(title: "Oops", message: error.localizedDescription), animated: true, completion: nil)
                }
                return
            }
            
            guard let objects = try? DataController.instance.viewContext.fetch(LeagueEntity.fetchRequest()) as? [LeagueEntity],
                !objects.contains(where: { $0.id == id }) else {
                    DispatchQueue.main.async {
                        self.present(UIAlertController.createAlert(title: "Oops", message: "This league is already saved."), animated: true, completion: nil)
                    }
                return
            }
            
            let newEntity = LeagueEntity(context: DataController.instance.viewContext)
            newEntity.id = id
            newEntity.name = league.name
            DataController.instance.viewContext.saveChanges()
            
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
