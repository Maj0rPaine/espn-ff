//
//  DataController.swift
//  espn-ff
//
//  Created by Chris Paine on 10/2/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    static let shared = DataController(modelName: "espn-ff")
    
    let persisentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return persisentContainer.viewContext
    }
    
    var backgroundContext: NSManagedObjectContext!
    
    init(modelName: String) {
        persisentContainer = NSPersistentContainer(name: modelName)
    }
    
    func configureContexts() {
        backgroundContext = persisentContainer.newBackgroundContext()
        
        // Set merge changes and policies
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        // Background context has authority over foreground
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        // Foreground context will follow what's in store
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    
    func load(completion: (() -> Void)? = nil) {
        persisentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError()
            }

            self.configureContexts()

            completion?()
        }
    }
}

extension NSManagedObjectContext {
    func saveChanges() {
        // Only save if there are uncommitted changes
        if self.hasChanges {
            do {
                try save()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    func count(with request: NSFetchRequest<NSFetchRequestResult>) -> Int {
        do {
            return try count(for: request)
        } catch let error {
            print(error.localizedDescription)
            return 0
        }
    }
    
    func fetchLeagues() -> [LeagueEntity]? {
        guard let objects = try? fetch(LeagueEntity.fetchRequest()) as? [LeagueEntity] else { return nil }
        return objects
    }
    
    func saveLeague(_ league: League) -> (league: LeagueEntity?, error: Error?) {
        guard let objects = fetchLeagues(),
            let id = league.leagueId,
            !objects.contains(where: { $0.id == "\(id)" }) else {
                return (nil, CoreDataError.entityAlreadySaved("This league is already saved."))
        }
        
        return (LeagueEntity(league: league, context: self), nil)
    }
}

enum CoreDataError: Error, LocalizedError {
    case entityAlreadySaved(String?)
    
    var errorDescription: String? {
        switch self {
        case .entityAlreadySaved(let message): return message ?? "Already saved."
        }
    }
}
