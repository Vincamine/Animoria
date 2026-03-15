//
//  LocationDetailView.swift
//  Animoria
//
//  Migrated to use DataManager (Phase 1.1)
//

import SwiftUI

struct LocationDetailView: View {
    let location: Location
    @StateObject private var dataManager = DataManager.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var showARView = false
    
    private var roundedShape: some Shape {
        RoundedRectangle(cornerRadius: 25)
    }
    
    private var backgroundColor: Color {
        Color(hex: location.colorHex) ?? .blue.opacity(0.2)
    }
    
    private var locationSpecies: [Species] {
        dataManager.species(for: location.id)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundLayer
                contentLayer(in: geometry)
            }
        }
        .overlay(closeButton, alignment: .topTrailing)
        .fullScreenCover(isPresented: $showARView) {
            // TODO: Update ARStickerView to work with new Species model
            // ARStickerView(species: locationSpecies)
            Text("AR View - Coming soon!")
                .font(.largeTitle)
                .overlay(
                    Button("Close") {
                        showARView = false
                    }
                    .padding(),
                    alignment: .topTrailing
                )
        }
    }
    
    private var backgroundLayer: some View {
        backgroundColor.edgesIgnoringSafeArea(.all)
    }
    
    private func contentLayer(in geometry: GeometryProxy) -> some View {
        VStack(spacing: 20) {
            ZStack {
                mainImage
                // Species markers can be added here when we have position data
                speciesList
            }
            .background(roundedShape.fill(backgroundColor))
            .clipShape(roundedShape)
            .scaleEffect(scale)
            .offset(offset)
            .gesture(interactionGestures(in: geometry))
            
            Spacer()
        }
        .padding()
    }
    
    private var mainImage: some View {
        Image(location.imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipShape(roundedShape)
            .padding(.horizontal)
    }
    
    private var speciesList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Species at \(location.name)")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(locationSpecies) { species in
                SpeciesRowView(species: species)
            }
        }
    }
    
    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.title)
                .foregroundColor(.gray)
                .padding()
        }
        .padding()
    }
    
    // MARK: - Gestures
    private func interactionGestures(in geometry: GeometryProxy) -> some Gesture {
        SimultaneousGesture(
            dragGesture(in: geometry),
            magnificationGesture(in: geometry)
        )
    }
    
    private func dragGesture(in geometry: GeometryProxy) -> some Gesture {
        DragGesture()
            .onChanged { handleDrag($0, in: geometry) }
            .onEnded { _ in lastOffset = offset }
    }
    
    private func magnificationGesture(in geometry: GeometryProxy) -> some Gesture {
        MagnificationGesture()
            .onChanged { handleMagnification($0, in: geometry) }
            .onEnded { _ in lastScale = 1.0 }
    }
    
    // MARK: - Gesture Handlers
    private func handleDrag(_ gesture: DragGesture.Value, in geometry: GeometryProxy) {
        let proposedOffset = CGSize(
            width: lastOffset.width + gesture.translation.width,
            height: lastOffset.height + gesture.translation.height
        )
        offset = limitOffset(geometry: geometry, proposedOffset: proposedOffset)
    }
    
    private func handleMagnification(_ value: CGFloat, in geometry: GeometryProxy) {
        let delta = value / lastScale
        lastScale = value
        let newScale = min(max(scale * delta, 1), 3)
        
        if newScale != scale {
            scale = newScale
            offset = limitOffset(geometry: geometry, proposedOffset: offset)
        }
    }
    
    // MARK: - Helper Methods
    private func limitOffset(geometry: GeometryProxy, proposedOffset: CGSize) -> CGSize {
        let minX = -(geometry.size.width * (scale - 1) / 2)
        let maxX = geometry.size.width * (scale - 1) / 2
        let minY = -(geometry.size.height * (scale - 1) / 2)
        let maxY = geometry.size.height * (scale - 1) / 2
        
        return CGSize(
            width: min(maxX, max(minX, proposedOffset.width)),
            height: min(maxY, max(minY, proposedOffset.height))
        )
    }
}

// MARK: - Species Row View

struct SpeciesRowView: View {
    let species: Species
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: {
            showingDetail = true
        }) {
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
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.white)
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(species.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(species.scientificName)
                        .font(.caption)
                        .italic()
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.white.opacity(0.8))
            .cornerRadius(12)
        }
        .sheet(isPresented: $showingDetail) {
            SpeciesDetailView(species: species)
        }
    }
}

// MARK: - Species Detail View

struct SpeciesDetailView: View {
    let species: Species
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Image
                    if let image = UIImage(named: species.imageName) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding()
                    }
                    
                    // Content
                    VStack(alignment: .leading, spacing: 16) {
                        Text(species.name)
                            .font(.largeTitle)
                            .bold()
                        
                        Text(species.scientificName)
                            .font(.title3)
                            .italic()
                            .foregroundColor(.secondary)
                        
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
                ToolbarItem(placement: .navigationBarTrailing) {
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

// MARK: - Color Extension (if not already defined elsewhere)

extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
