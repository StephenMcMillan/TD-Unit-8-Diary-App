//
//  DiaryCoreDataStack.swift
//  Diary
//
//  Created by Stephen McMillan on 14/02/2019.
//  Copyright © 2019 Stephen McMillan. All rights reserved.
//

import CoreData

// Core Data stack. Creates a persistent container etc.
class CoreDataStack {
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        return self.persistentStoreContainer.viewContext
    }()
    
    lazy var persistentStoreContainer: NSPersistentContainer = {
        
        let persistentStoreContainer = NSPersistentContainer(name: "Diary")
        persistentStoreContainer.loadPersistentStores(){ (storeDescription, error) in
            if let error = error {
                fatalError("Error loading persistent store. \(error)")
            }
        }
        
        return persistentStoreContainer
    }()
    
    
}
