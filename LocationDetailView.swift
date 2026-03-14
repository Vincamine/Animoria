//
//  LocationDetailView.swift
//  Animoria
//
//  Created by Wenxue Fang on 2/17/25.
//

import SwiftUI

struct LocationDetailView: View {
    @Binding var item: CardItem
    @Environment(\.dismiss) var dismiss
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    @State private var showARView = false
    
    private var roundedShape: some Shape {
        RoundedRectangle(cornerRadius: 25)
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
            ARStickerView(stickers: item.species.flatMap { $0.stickers })
        }
    }
    
    
    private var backgroundLayer: some View {
        item.color.edgesIgnoringSafeArea(.all)
    }
    
    private func contentLayer(in geometry: GeometryProxy) -> some View {
        VStack(spacing: 20) {
            ZStack {
                mainImage
                speciesMarkers(in: geometry)
            }
            .background(roundedShape.fill(item.color))
            .clipShape(roundedShape)
            .scaleEffect(scale)
            .offset(offset)
            .gesture(interactionGestures(in: geometry))
            
            // Add View after encountered all species
            GrandSlamView(
                foundSpecies: item.species.filter { $0.isFound },
                totalSpeciesCount: item.species.count,
                showARView: $showARView
            )
            .padding()
        }
    }
    
    private var mainImage: some View {
        Image(item.imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipShape(roundedShape)
            .padding(.horizontal)
    }
    
    private func speciesMarkers(in geometry: GeometryProxy) -> some View {
        ForEach(item.species) { speciesItem in
            if let index = item.species.firstIndex(where: { $0.id == speciesItem.id }) {
                SpeciesView(species: $item.species[index], cardColor: item.color)
                    .position(
                        x: geometry.size.width * speciesItem.position.x,
                        y: geometry.size.height * speciesItem.position.y
                    )
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
