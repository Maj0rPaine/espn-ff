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
    static let instance = DataController(modelName: "espn-ff")
    
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
}
