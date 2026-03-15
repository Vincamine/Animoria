//
//  PhotoGalleryView.swift
//  Animoria
//
//  Phase 2.2 - Photo Gallery for Captured Species Photos
//

import SwiftUI

struct PhotoGalleryView: View {
    let species: Species
    @StateObject private var discoveryManager = DiscoveryManager.shared
    @Environment(\.dismiss) var dismiss
    
    var discovery: SpeciesDiscovery? {
        discoveryManager.discovery(for: species.id)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                if let discovery = discovery, let photoData = discovery.photoData,
                   let uiImage = UIImage(data: photoData) {
                    PhotoDetailView(image: uiImage, species: species, discoveredAt: discovery.discoveredAt)
                } else if let referenceImage = UIImage(named: species.imageName) {
                    // Fallback to reference image if no photo captured
                    VStack(spacing: 20) {
                        Image(uiImage: referenceImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding()
                        
                        VStack(spacing: 8) {
                            Text("No Photo Captured")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("This is the reference image for \(species.name)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal)
                    }
                } else {
                    ContentUnavailableView(
                        "No Photo Available",
                        systemImage: "photo.badge.exclamationmark",
                        description: Text("No photo was captured for this species")
                    )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(species.name)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        }
    }
}

// MARK: - Photo Detail View

struct PhotoDetailView: View {
    let image: UIImage
    let species: Species
    let discoveredAt: Date
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var showInfo = true
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Photo
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .offset(offset)
                    .gesture(
                        SimultaneousGesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    let delta = value / lastScale
                                    lastScale = value
                                    scale = min(max(scale * delta, 1), 4)
                                }
                                .onEnded { _ in
                                    lastScale = 1.0
                                    withAnimation(.spring(response: 0.3)) {
                                        if scale < 1.2 {
                                            scale = 1.0
                                            offset = .zero
                                        }
                                    }
                                },
                            DragGesture()
                                .onChanged { value in
                                    if scale > 1 {
                                        offset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                    }
                                }
                                .onEnded { _ in
                                    lastOffset = offset
                                }
                        )
                    )
                    .onTapGesture {
                        withAnimation {
                            showInfo.toggle()
                        }
                    }
                
                // Info overlay
                if showInfo {
                    VStack {
                        Spacer()
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(species.name)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text(species.scientificName)
                                    .font(.caption)
                                    .italic()
                                    .foregroundColor(.white.opacity(0.8))
                                Text("Discovered \(discoveredAt.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            Spacer()
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                    }
                    .transition(.move(edge: .bottom))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Photo Grid View (for multiple photos in future)

struct PhotoGridView: View {
    let photos: [Data]
    @State private var selectedPhoto: Data?
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(photos.indices, id: \.self) { index in
                    if let uiImage = UIImage(data: photos[index]) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .onTapGesture {
                                selectedPhoto = photos[index]
                            }
                    }
                }
            }
            .padding()
        }
        .fullScreenCover(item: Binding(
            get: { selectedPhoto.map { IdentifiableData(data: $0) } },
            set: { selectedPhoto = $0?.data }
        )) { identifiableData in
            if let uiImage = UIImage(data: identifiableData.data) {
                FullScreenPhotoView(image: uiImage)
            }
        }
    }
}

struct IdentifiableData: Identifiable {
    let id = UUID()
    let data: Data
}

struct FullScreenPhotoView: View {
    let image: UIImage
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white.opacity(0.8))
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}

#Preview {
    PhotoGalleryView(species: Species.preview)
}
