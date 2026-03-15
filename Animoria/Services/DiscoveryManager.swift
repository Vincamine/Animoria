//
//  DiscoveryManager.swift
//  Animoria
//
//  Phase 2.1 - Discovery Flow & Species Collection
//

import Foundation
import CoreData
import Combine

@MainActor
class DiscoveryManager: ObservableObject {
    static let shared = DiscoveryManager()
    
    @Published private(set) var discoveries: [String: SpeciesDiscovery] = [:] // speciesId -> discovery
    @Published private(set) var isLoaded = false
    
    private let context: NSManagedObjectContext
    
    private init() {
        // Use shared Core Data stack
        context = CoreDataStack.shared.context
        
        Task {
            await loadDiscoveries()
        }
    }
    
    // MARK: - Load Discoveries
    
    func loadDiscoveries() async {
        let request = SpeciesDiscoveryEntity.fetchRequest()
        
        do {
            let entities = try context.fetch(request)
            var loadedDiscoveries: [String: SpeciesDiscovery] = [:]
            
            for entity in entities {
                let discovery = SpeciesDiscovery(
                    id: entity.id ?? UUID(),
                    speciesId: entity.speciesId ?? "",
                    discoveredAt: entity.discoveredAt ?? Date(),
                    photoData: entity.photoData
                )
                loadedDiscoveries[discovery.speciesId] = discovery
            }
            
            self.discoveries = loadedDiscoveries
            self.isLoaded = true
            print("Loaded \(discoveries.count) discoveries from Core Data")
        } catch {
            print("Failed to load discoveries: \(error.localizedDescription)")
            self.isLoaded = true
        }
    }
    
    // MARK: - Discovery Status
    
    func isDiscovered(_ speciesId: String) -> Bool {
        discoveries[speciesId] != nil
    }
    
    func discovery(for speciesId: String) -> SpeciesDiscovery? {
        discoveries[speciesId]
    }
    
    func discoveredCount(for locationId: String, dataManager: DataManager) -> Int {
        let locationSpecies = dataManager.species(for: locationId)
        return locationSpecies.filter { isDiscovered($0.id) }.count
    }
    
    func totalCount(for locationId: String, dataManager: DataManager) -> Int {
        dataManager.species(for: locationId).count
    }
    
    var totalDiscoveries: Int {
        discoveries.count
    }
    
    // MARK: - Discover Species
    
    func discoverSpecies(_ speciesId: String, photoData: Data? = nil, completion: @escaping (Bool) -> Void) {
        // Check if already discovered
        guard !isDiscovered(speciesId) else {
            print("Species already discovered: \(speciesId)")
            completion(false)
            return
        }
        
        // Create discovery record
        let discovery = SpeciesDiscovery(
            speciesId: speciesId,
            photoData: photoData
        )
        
        // Save to Core Data
        let entity = SpeciesDiscoveryEntity(context: context)
        entity.id = discovery.id
        entity.speciesId = discovery.speciesId
        entity.discoveredAt = discovery.discoveredAt
        entity.photoData = discovery.photoData
        
        do {
            try context.save()
            discoveries[speciesId] = discovery
            print("✅ Discovered species: \(speciesId)")
            
            // Check achievements
            Task { @MainActor in
                AchievementManager.shared.checkAchievements(
                    discoveryManager: self,
                    dataManager: DataManager.shared
                )
            }
            
            completion(true)
        } catch {
            print("Failed to save discovery: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    // MARK: - Update Photo
    
    func updatePhoto(for speciesId: String, photoData: Data) {
        guard var discovery = discoveries[speciesId] else { return }
        
        // Update in-memory
        discovery.photoData = photoData
        discoveries[speciesId] = discovery
        
        // Update Core Data
        let request = SpeciesDiscoveryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "speciesId == %@", speciesId)
        
        do {
            let entities = try context.fetch(request)
            if let entity = entities.first {
                entity.photoData = photoData
                try context.save()
                print("✅ Updated photo for species: \(speciesId)")
            }
        } catch {
            print("Failed to update photo: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Clear All (for testing)
    
    func clearAllDiscoveries() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SpeciesDiscoveryEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
            discoveries.removeAll()
            print("🗑️ Cleared all discoveries")
        } catch {
            print("Failed to clear discoveries: \(error.localizedDescription)")
        }
    }
}

// MARK: - Species Discovery Model

struct SpeciesDiscovery: Identifiable {
    let id: UUID
    let speciesId: String
    let discoveredAt: Date
    var photoData: Data?
    
    init(id: UUID = UUID(), speciesId: String, discoveredAt: Date = Date(), photoData: Data? = nil) {
        self.id = id
        self.speciesId = speciesId
        self.discoveredAt = discoveredAt
        self.photoData = photoData
    }
}

// MARK: - Core Data Entity Extension

extension SpeciesDiscoveryEntity {
    static func fetchRequest() -> NSFetchRequest<SpeciesDiscoveryEntity> {
        return NSFetchRequest<SpeciesDiscoveryEntity>(entityName: "SpeciesDiscoveryEntity")
    }
}
