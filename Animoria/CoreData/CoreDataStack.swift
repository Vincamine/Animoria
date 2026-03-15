//
//  CoreDataStack.swift
//  Animoria
//
//  Phase 2.1 - Core Data Stack Configuration
//

import Foundation
import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()
    
    lazy var persistentContainer: NSPersistentContainer = {
        // Create model programmatically
        let model = NSManagedObjectModel()
        
        // SpeciesDiscoveryEntity
        let discoveryEntity = NSEntityDescription()
        discoveryEntity.name = "SpeciesDiscoveryEntity"
        discoveryEntity.managedObjectClassName = NSStringFromClass(SpeciesDiscoveryEntity.self)
        
        // Attributes
        let idAttribute = NSAttributeDescription()
        idAttribute.name = "id"
        idAttribute.attributeType = .UUIDAttributeType
        idAttribute.isOptional = false
        
        let speciesIdAttribute = NSAttributeDescription()
        speciesIdAttribute.name = "speciesId"
        speciesIdAttribute.attributeType = .stringAttributeType
        speciesIdAttribute.isOptional = false
        
        let discoveredAtAttribute = NSAttributeDescription()
        discoveredAtAttribute.name = "discoveredAt"
        discoveredAtAttribute.attributeType = .dateAttributeType
        discoveredAtAttribute.isOptional = false
        
        let photoDataAttribute = NSAttributeDescription()
        photoDataAttribute.name = "photoData"
        photoDataAttribute.attributeType = .binaryDataAttributeType
        photoDataAttribute.isOptional = true
        photoDataAttribute.allowsExternalBinaryDataStorage = true // Store large photos efficiently
        
        discoveryEntity.properties = [idAttribute, speciesIdAttribute, discoveredAtAttribute, photoDataAttribute]
        
        // Add entity to model
        model.entities = [discoveryEntity]
        
        // Create container
        let container = NSPersistentContainer(name: "Animoria", managedObjectModel: model)
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("❌ Core Data failed to load: \(error.localizedDescription)")
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            } else {
                print("✅ Core Data loaded successfully")
                print("Store URL: \(description.url?.absoluteString ?? "unknown")")
            }
        }
        
        // Merge policy for conflicts
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Core Data save error: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
