//
//  LeagueTableView.swift
//  espn-ff
//
//  Created by Chris Paine on 10/1/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import UIKit
import CoreData

class LeagueTableView: UITableView, UITableViewDataSource {
    var fetchedResultsController: NSFetchedResultsController<LeagueEntity>!
    
    lazy var emptyView: UIStackView = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .light)
        label.numberOfLines = 0
        label.text = "Add leagues here to view \n weekly matchups on your watch.\n\nOpen ESPN and log in before \n adding private leagues."
        label.textAlignment = .center
        let stackView = UIStackView(arrangedSubviews: [label])
        return stackView
    }()
        
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        dataSource = self
        
        let fetchRequest: NSFetchRequest<LeagueEntity> = LeagueEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        
        fetchedResultsController = NSFetchedResultsController<LeagueEntity>(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: "League")
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        fetchedResultsController = nil        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        updateBackgroundView()
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?.first else { return 0 }
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entity = fetchedResultsController.object(at: indexPath)
        return LeagueCell(entity: entity)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete: deleteEntity(at: indexPath)
        default: () // Unsupported
        }
    }
    
    func deleteEntity(at indexPath: IndexPath) {
        let entityToDelete = fetchedResultsController.object(at: indexPath)
        DataController.shared.viewContext.delete(entityToDelete)
        DataController.shared.viewContext.saveChanges()
    }
    
    func updateBackgroundView() {
        if let objects = fetchedResultsController.fetchedObjects, !objects.isEmpty {
            backgroundView = nil
        } else {
            backgroundView = emptyView
        }
    }
}

extension LeagueTableView: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            deleteRows(at: [indexPath!], with: .fade)
        case .update:
            reloadRows(at: [indexPath!], with: .fade)
        case .move:
            moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default:
            reloadData()
        }
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        endUpdates()
    }
}
