//
//  DataManager.swift
//  Animoria
//
//  Phase 1.1 - Data Architecture
//

import Foundation
import Combine

@MainActor
class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published private(set) var locations: [Location] = []
    @Published private(set) var species: [Species] = []
    @Published private(set) var isLoaded = false
    
    private init() {
        Task {
            await loadData()
        }
    }
    
    // MARK: - Data Loading
    
    func loadData() async {
        // Load locations
        if let locationsURL = Bundle.main.url(forResource: "locations", withExtension: "json"),
           let locationsData = try? Data(contentsOf: locationsURL) {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([Location].self, from: locationsData) {
                self.locations = decoded
            }
        }
        
        // Load species
        if let speciesURL = Bundle.main.url(forResource: "species", withExtension: "json"),
           let speciesData = try? Data(contentsOf: speciesURL) {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([Species].self, from: speciesData) {
                self.species = decoded
            }
        }
        
        // Fallback to bundled sample data if JSON loading fails
        if locations.isEmpty {
            loadFallbackData()
        }
        
        isLoaded = true
    }
    
    // MARK: - Queries
    
    func location(withId id: String) -> Location? {
        locations.first { $0.id == id }
    }
    
    func species(for locationId: String) -> [Species] {
        species.filter { $0.locationId == locationId }
    }
    
    func species(withId id: String) -> Species? {
        species.first { $0.id == id }
    }
    
    // MARK: - Location Updates (from LocationManager)
    
    func updateDistance(for locationId: String, distance: Double?) {
        guard let index = locations.firstIndex(where: { $0.id == locationId }) else { return }
        var updated = locations[index]
        updated.distanceFromUser = distance
        locations[index] = updated
    }
    
    func updateOnSiteStatus(for locationId: String, isOnSite: Bool) {
        guard let index = locations.firstIndex(where: { $0.id == locationId }) else { return }
        var updated = locations[index]
        updated.isUserOnSite = isOnSite
        locations[index] = updated
    }
    
    // MARK: - Fallback Data
    
    private func loadFallbackData() {
        // Channel Islands
        let channelIslands = Location(
            id: "channel-islands",
            name: "Channel Islands",
            subtitle: "Ventura, California",
            imageName: "ChannelIslandsLight",
            colorHex: "#D7F2FF",
            coordinate: Location.Coordinate(latitude: 34.0069, longitude: -119.7785),
            radius: 5000,
            speciesIds: ["island-fox", "island-deer-mouse", "gopher-snake", "island-night-lizard"]
        )
        
        let sanMateo = Location(
            id: "san-mateo-campground",
            name: "San Mateo Campground",
            subtitle: "San Diego County, California",
            imageName: "SanMateoCampgroundLight",
            colorHex: "#E4FFEC",
            coordinate: Location.Coordinate(latitude: 33.3856, longitude: -117.5931),
            radius: 2000,
            speciesIds: ["mule-deer", "california-quail", "western-fence-lizard"]
        )
        
        locations = [channelIslands, sanMateo]
        
        // Species for Channel Islands
        let islandFox = Species(
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
        
        let deerMouse = Species(
            id: "island-deer-mouse",
            locationId: "channel-islands",
            name: "Island Deer Mouse",
            scientificName: "Peromyscus maniculatus",
            appearance: "A small, brownish mouse with large eyes and ears, adapted to island life.",
            habitat: "Found on all eight Channel Islands, with each island hosting a unique subspecies.",
            feeding: "Omnivorous, feeding on seeds, fruits, insects, and occasionally carrion.",
            reproduction: "Breeds year-round, with females producing multiple litters of 2-5 pups.",
            quickFacts: "Tiny traveler, swift and sly, island hunter, watchful eye.",
            imageName: "island_deer_mouse"
        )
        
        let gopherSnake = Species(
            id: "gopher-snake",
            locationId: "channel-islands",
            name: "Gopher Snake",
            scientificName: "Pituophis catenifer",
            appearance: "A non-venomous snake with yellowish-brown scales and dark blotches along its body.",
            habitat: "Found in a variety of habitats, including grasslands, chaparral, and coastal dunes.",
            feeding: "Carnivorous, feeding on rodents, birds, eggs, and lizards.",
            reproduction: "Lays eggs in the summer, with hatchlings emerging in early fall.",
            quickFacts: "Hisses loud, but strikes no fear; a harmless guardian living near.",
            imageName: "gopher_snake"
        )
        
        let nightLizard = Species(
            id: "island-night-lizard",
            locationId: "channel-islands",
            name: "Island Night Lizard",
            scientificName: "Xantusia riversiana",
            appearance: "A small, brownish-gray lizard with a flat body and granular scales.",
            habitat: "Lives in rock crevices, under logs, and in dense vegetation on the Channel Islands.",
            feeding: "Omnivorous, feeding on insects, spiders, and plant matter.",
            reproduction: "Gives birth to live young rather than laying eggs, with 1-3 offspring per year.",
            quickFacts: "Hidden by day, so still, so shy; nightfall wakes its watchful eye.",
            imageName: "island_night_lizard"
        )
        
        species = [islandFox, deerMouse, gopherSnake, nightLizard]
    }
}
