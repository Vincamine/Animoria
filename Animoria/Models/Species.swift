//
//  Species.swift
//  Animoria
//
//  Phase 1.1 - Data Architecture
//

import SwiftUI

struct Species: Identifiable, Codable {
    let id: String
    let locationId: String
    let name: String
    let scientificName: String
    let appearance: String
    let habitat: String
    let feeding: String
    let reproduction: String
    let quickFacts: String
    let imageName: String
    
    // Computed description for detail view
    var fullDescription: String {
        """
        Scientific Name: \(scientificName)
        
        Appearance: \(appearance)
        
        Habitat: \(habitat)
        
        Feeding: \(feeding)
        
        Reproduction: \(reproduction)
        
        Quick and Fun Facts: \(quickFacts)
        """
    }
}

// MARK: - User Discovery (stored in Core Data, linked by species ID)
struct SpeciesDiscovery: Identifiable {
    let id: UUID
    let speciesId: String
    let discoveredAt: Date
    let photoData: Data?
    
    init(speciesId: String, photoData: Data? = nil) {
        self.id = UUID()
        self.speciesId = speciesId
        self.discoveredAt = Date()
        self.photoData = photoData
    }
}

// MARK: - Sample/Preview Data
extension Species {
    static let preview = Species(
        id: "island-fox",
        locationId: "channel-islands",
        name: "Island Fox",
        scientificName: "Urocyon littoralis",
        appearance: "A small fox with a reddish-gray coat, black-tipped tail, and large ears.",
        habitat: "Only found on six of the eight Channel Islands off the coast of Southern California.",
        feeding: "Omnivorous, feeding on insects, fruits, birds, and small mammals.",
        reproduction: "Breeds in early spring, with 2-3 pups per litter.",
        quickFacts: "Once near gone, now strong and free, island fox, survivor of the sea.",
        imageName: "island_fox"
    )
}
