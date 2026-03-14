//
//  MapView.swift
//  Animoria
//
//  Phase 1.2 & 1.3 - MapKit Integration & GPS
//

import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var locationManager = LocationManager.shared
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var selectedLocation: Location?
    @State private var showingLocationDetail = false
    
    var body: some View {
        ZStack {
            Map(position: $cameraPosition, selection: $selectedLocation) {
                // User location
                if locationManager.canUseLocation {
                    UserAnnotation()
                }
                
                // Location markers
                ForEach(dataManager.locations) { location in
                    Annotation(
                        location.name,
                        coordinate: location.coordinate.clLocation,
                        anchor: .bottom
                    ) {
                        LocationMarkerView(
                            location: location,
                            isSelected: selectedLocation?.id == location.id
                        )
                    }
                    .tag(location)
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
            
            // Location permission prompt
            if !locationManager.canUseLocation && locationManager.authorizationStatus == .notDetermined {
                VStack {
                    Spacer()
                    locationPermissionBanner
                        .padding()
                }
            }
            
            // Selected location card
            if let location = selectedLocation {
                VStack {
                    Spacer()
                    LocationPreviewCard(location: location) {
                        showingLocationDetail = true
                    }
                    .padding()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .animation(.spring(response: 0.3), value: selectedLocation)
            }
        }
        .onAppear {
            locationManager.setDataManager(dataManager)
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            
            // Center on California
            cameraPosition = .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 34.5, longitude: -119.0),
                span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)
            ))
        }
        .onChange(of: selectedLocation) { _, newValue in
            if let location = newValue {
                withAnimation {
                    cameraPosition = .region(MKCoordinateRegion(
                        center: location.coordinate.clLocation,
                        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                    ))
                }
            }
        }
        .sheet(isPresented: $showingLocationDetail) {
            if let location = selectedLocation {
                LocationSheetView(location: location)
            }
        }
    }
    
    private var locationPermissionBanner: some View {
        HStack {
            Image(systemName: "location.fill")
                .foregroundColor(.blue)
            
            VStack(alignment: .leading) {
                Text("Enable Location")
                    .font(.headline)
                Text("See your position and nearby wildlife")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("Enable") {
                locationManager.requestWhenInUseAuthorization()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Location Marker

struct LocationMarkerView: View {
    let location: Location
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(location.color)
                    .frame(width: isSelected ? 50 : 40, height: isSelected ? 50 : 40)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                
                Image(systemName: "leaf.fill")
                    .font(isSelected ? .title2 : .body)
                    .foregroundColor(.green)
            }
            
            // Triangle pointer
            Triangle()
                .fill(location.color)
                .frame(width: 12, height: 8)
                .offset(y: -2)
            
            // On-site badge
            if location.isUserOnSite {
                Text("HERE")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(.green)
                    .clipShape(Capsule())
                    .offset(y: 4)
            }
        }
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Location Preview Card

struct LocationPreviewCard: View {
    let location: Location
    let onTap: () -> Void
    
    @StateObject private var locationManager = LocationManager.shared
    @StateObject private var dataManager = DataManager.shared
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Location image
                if let image = UIImage(named: location.imageName) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(location.color)
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                }
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(location.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
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
                    
                    HStack {
                        // Species count
                        let speciesCount = dataManager.species(for: location.id).count
                        Label("\(speciesCount) species", systemImage: "pawprint.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        // Distance
                        if let distance = locationManager.formattedDistance(to: location.coordinate.clLocation) {
                            Text("•")
                                .foregroundColor(.secondary)
                            Label(distance, systemImage: "location.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(.ultraThickMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Location Sheet View

struct LocationSheetView: View {
    let location: Location
    @Environment(\.dismiss) var dismiss
    @StateObject private var dataManager = DataManager.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Hero image
                    if let image = UIImage(named: location.imageName) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding(.horizontal)
                    }
                    
                    // Location info
                    VStack(alignment: .leading, spacing: 8) {
                        Text(location.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(location.subtitle)
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    // Species list
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Species to Discover")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        let species = dataManager.species(for: location.id)
                        ForEach(species) { species in
                            SpeciesRowView(species: species)
                                .padding(.horizontal)
                        }
                    }
                    
                    Spacer(minLength: 40)
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

struct SpeciesRowView: View {
    let species: Species
    
    var body: some View {
        HStack(spacing: 12) {
            // Species image
            if let image = UIImage(named: species.imageName) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "pawprint.fill")
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(species.name)
                    .font(.headline)
                Text(species.scientificName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

#Preview {
    MapView()
}
