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
        guard let id = league.leagueId else { return (nil, CoreDataError.saveFailed) }
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = LeagueEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %d", #keyPath(LeagueEntity.id), Int32(id))
        
        if count(with: fetchRequest) > 0 {
            return (nil, CoreDataError.entityAlreadySaved("This league is already saved."))
        }
        
        return (LeagueEntity(league: league, context: self), nil)
    }
    
    func deleteLeagues() {
        do {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = LeagueEntity.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            deleteRequest.resultType = .resultTypeObjectIDs
            let result = try execute(deleteRequest) as? NSBatchDeleteResult
            let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: result?.result as? [NSManagedObjectID] ?? []]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self])
        } catch let error {
            print("Batch Delete Error: \(error)")
        }
    }
    
    func fetchTeam(for league: Int32, with teamId: Int16) -> TeamEntity? {
        let fetchRequest: NSFetchRequest<TeamEntity> = TeamEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "(%K == %d) AND (%K == %d)", #keyPath(TeamEntity.league.id), league, #keyPath(TeamEntity.id), teamId)
        
        do {
            let teams = try fetch(fetchRequest)
            return teams.first
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func fetchPrimaryTeam(with id: Int16) -> TeamEntity? {
        let fetchRequest: NSFetchRequest<TeamEntity> = TeamEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %d", #keyPath(TeamEntity.league.primaryTeamId), id)
        
        do {
            let teams = try fetch(fetchRequest)
            return teams.first
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
}

enum CoreDataError: Error, LocalizedError {
    case entityAlreadySaved(String?)
    case saveFailed
    case fetchFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .entityAlreadySaved(let message): return message ?? "Already saved."
        case .saveFailed: return "Save failed"
        case .fetchFailed(let message): return "Fetch failed: \(message)"
        }
    }
}
