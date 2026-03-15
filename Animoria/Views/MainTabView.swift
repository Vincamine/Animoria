//
//  MainTabView.swift
//  Animoria
//
//  Phase 1.2 - Navigation Structure
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var locationManager = LocationManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Map Tab
            MapView()
                .tabItem {
                    Label("Explore", systemImage: "map.fill")
                }
                .tag(0)
            
            // Locations Tab (original card view)
            LocationsListView()
                .tabItem {
                    Label("Locations", systemImage: "list.bullet")
                }
                .tag(1)
            
            // Collection Tab (future: discovered species)
            CollectionView()
                .tabItem {
                    Label("Collection", systemImage: "square.grid.2x2.fill")
                }
                .tag(2)
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
        .onAppear {
            setupManagers()
        }
    }
    
    private func setupManagers() {
        // Connect managers
        locationManager.setDataManager(dataManager)
        
        // Request notification permission
        Task {
            _ = await notificationManager.requestAuthorization()
        }
        
        // Setup geofences when locations are loaded
        if dataManager.isLoaded {
            locationManager.setupGeofences(for: dataManager.locations)
        }
    }
}

// MARK: - Locations List View (Card-based)

struct LocationsListView: View {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var locationManager = LocationManager.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(dataManager.locations) { location in
                        LocationCardView(location: location)
                    }
                }
                .padding()
            }
            .navigationTitle("Locations")
        }
    }
}

struct LocationCardView: View {
    let location: Location
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var locationManager = LocationManager.shared
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: { showingDetail = true }) {
            VStack(spacing: 0) {
                // Image
                if let image = UIImage(named: location.imageName) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                }
                
                // Info bar
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(location.name)
                                .font(.headline)
                            
                            if location.isUserOnSite {
                                Text("ON SITE")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(.green)
                                    .clipShape(Capsule())
                            }
                        }
                        
                        Text(location.subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        let speciesCount = dataManager.species(for: location.id).count
                        Text("\(speciesCount) species")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if let distance = locationManager.formattedDistance(to: location.coordinate.clLocation) {
                            Text(distance)
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding()
                .background(location.color)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingDetail) {
            LocationSheetView(location: location)
        }
    }
}

// MARK: - Collection View

struct CollectionView: View {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var discoveryManager = DiscoveryManager.shared
    @State private var selectedSpecies: Species?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(dataManager.species) { species in
                        SpeciesCollectionCard(species: species)
                            .onTapGesture {
                                if discoveryManager.isDiscovered(species.id) {
                                    selectedSpecies = species
                                }
                            }
                    }
                }
                .padding()
            }
            .navigationTitle("Collection")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Text("\(discoveryManager.totalDiscoveries)/\(dataManager.species.count)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            }
            .sheet(item: $selectedSpecies) { species in
                SpeciesDetailSheet(species: species)
            }
        }
    }
}

// MARK: - Species Collection Card

struct SpeciesCollectionCard: View {
    let species: Species
    @StateObject private var discoveryManager = DiscoveryManager.shared
    
    var isDiscovered: Bool {
        discoveryManager.isDiscovered(species.id)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                if let image = UIImage(named: species.imageName) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .grayscale(isDiscovered ? 0 : 1.0)
                        .opacity(isDiscovered ? 1.0 : 0.4)
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Image(systemName: isDiscovered ? "checkmark.circle.fill" : "lock.fill")
                                .font(.title)
                                .foregroundColor(isDiscovered ? .green : .gray)
                        )
                }
                
                // Discovered badge
                if isDiscovered {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Circle()
                                .fill(.green)
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                )
                        }
                    }
                    .frame(width: 100, height: 100)
                }
                
                // Photo indicator
                if let discovery = discoveryManager.discovery(for: species.id),
                   discovery.photoData != nil {
                    VStack {
                        Spacer()
                        HStack {
                            Circle()
                                .fill(.blue)
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Image(systemName: "camera.fill")
                                        .font(.caption2)
                                        .foregroundColor(.white)
                                )
                            Spacer()
                        }
                    }
                    .frame(width: 100, height: 100)
                }
            }
            
            Text(isDiscovered ? species.name : "???")
                .font(.caption)
                .lineLimit(1)
                .foregroundColor(isDiscovered ? .primary : .secondary)
                .fontWeight(isDiscovered ? .medium : .regular)
        }
    }
}

// MARK: - Species Detail Sheet

struct SpeciesDetailSheet: View {
    let species: Species
    @StateObject private var discoveryManager = DiscoveryManager.shared
    @Environment(\.dismiss) var dismiss
    
    var discovery: SpeciesDiscovery? {
        discoveryManager.discovery(for: species.id)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Photo or species image
                    if let discovery = discovery, let photoData = discovery.photoData,
                       let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding(.horizontal)
                    } else if let image = UIImage(named: species.imageName) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding(.horizontal)
                    }
                    
                    // Species info
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(species.name)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                
                                Text(species.scientificName)
                                    .font(.title3)
                                    .italic()
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if let discovery = discovery {
                                VStack(alignment: .trailing) {
                                    Image(systemName: "checkmark.seal.fill")
                                        .font(.title)
                                        .foregroundColor(.green)
                                    Text("Discovered")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(discovery.discoveredAt.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        Divider()
                        
                        DetailSection(title: "Appearance", content: species.appearance)
                        DetailSection(title: "Habitat", content: species.habitat)
                        DetailSection(title: "Feeding", content: species.feeding)
                        DetailSection(title: "Reproduction", content: species.reproduction)
                        DetailSection(title: "Quick Facts", content: species.quickFacts)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DetailSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Profile View

struct ProfileView: View {
    @StateObject private var locationManager = LocationManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var discoveryManager = DiscoveryManager.shared
    @StateObject private var dataManager = DataManager.shared
    
    var visitedLocations: Int {
        dataManager.locations.filter { location in
            discoveryManager.discoveredCount(for: location.id, dataManager: dataManager) > 0
        }.count
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section("Stats") {
                    HStack {
                        Label("Species Discovered", systemImage: "pawprint.fill")
                        Spacer()
                        Text("\(discoveryManager.totalDiscoveries)/\(dataManager.species.count)")
                            .foregroundColor(discoveryManager.totalDiscoveries > 0 ? .green : .secondary)
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Label("Locations Visited", systemImage: "mappin.circle.fill")
                        Spacer()
                        Text("\(visitedLocations)/\(dataManager.locations.count)")
                            .foregroundColor(visitedLocations > 0 ? .blue : .secondary)
                            .fontWeight(.medium)
                    }
                }
                
                Section("Permissions") {
                    HStack {
                        Label("Location", systemImage: "location.fill")
                        Spacer()
                        Text(locationStatusText)
                            .foregroundColor(locationStatusColor)
                    }
                    
                    HStack {
                        Label("Notifications", systemImage: "bell.fill")
                        Spacer()
                        Text(notificationManager.isAuthorized ? "Enabled" : "Disabled")
                            .foregroundColor(notificationManager.isAuthorized ? .green : .red)
                    }
                }
                
                Section("About") {
                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
    
    private var locationStatusText: String {
        switch locationManager.authorizationStatus {
        case .authorizedAlways: return "Always"
        case .authorizedWhenInUse: return "When In Use"
        case .denied: return "Denied"
        case .restricted: return "Restricted"
        case .notDetermined: return "Not Set"
        @unknown default: return "Unknown"
        }
    }
    
    private var locationStatusColor: Color {
        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse: return .green
        case .denied, .restricted: return .red
        default: return .orange
        }
    }
}

#Preview {
    MainTabView()
}
