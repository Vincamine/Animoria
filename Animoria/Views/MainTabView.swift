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

// MARK: - Collection View (Placeholder)

struct CollectionView: View {
    @StateObject private var dataManager = DataManager.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(dataManager.species) { species in
                        VStack {
                            if let image = UIImage(named: species.imageName) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .grayscale(1.0) // Greyed out until discovered
                                    .opacity(0.5)
                            } else {
                                Circle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Image(systemName: "questionmark")
                                            .foregroundColor(.gray)
                                    )
                            }
                            
                            Text(species.name)
                                .font(.caption)
                                .lineLimit(1)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Collection")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Text("0/\(dataManager.species.count)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// MARK: - Profile View (Placeholder)

struct ProfileView: View {
    @StateObject private var locationManager = LocationManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    
    var body: some View {
        NavigationStack {
            List {
                Section("Stats") {
                    HStack {
                        Label("Species Found", systemImage: "pawprint.fill")
                        Spacer()
                        Text("0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("Locations Visited", systemImage: "mappin.circle.fill")
                        Spacer()
                        Text("0")
                            .foregroundColor(.secondary)
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
