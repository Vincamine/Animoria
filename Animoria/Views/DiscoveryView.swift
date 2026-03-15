//
//  DiscoveryView.swift
//  Animoria
//
//  Phase 2.2 - Species Discovery Flow with Camera Integration
//

import SwiftUI

struct DiscoveryView: View {
    let species: Species
    let location: Location
    @Environment(\.dismiss) var dismiss
    @StateObject private var discoveryManager = DiscoveryManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    
    @State private var showingCelebration = false
    @State private var isDiscovering = false
    @State private var discovered = false
    @State private var showPhotoOptions = false
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                if !discovered {
                    if !showPhotoOptions {
                        // Initial discovery prompt
                        discoveryPromptView
                    } else {
                        // Photo capture options
                        photoOptionsView
                    }
                } else {
                    // Celebration
                    CelebrationView(species: species, capturedImage: capturedImage)
                }
                
                Spacer()
                
                // Close button
                if !discovered {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .transition(.opacity)
        .sheet(isPresented: $showCamera) {
            CameraView { image in
                capturedImage = image
                completeDiscovery()
            }
        }
    }
    
    // MARK: - Discovery Prompt View
    
    private var discoveryPromptView: some View {
        VStack(spacing: 20) {
            // Species image
            if let image = UIImage(named: species.imageName) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.3), radius: 20)
            }
            
            VStack(spacing: 8) {
                Text("New Species Found!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(species.name)
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.9))
                
                Text(species.scientificName)
                    .font(.callout)
                    .italic()
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Text("You're at \(location.name). Would you like to take a photo or just record the discovery?")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            // Primary action button
            Button(action: {
                withAnimation {
                    showPhotoOptions = true
                }
            }) {
                HStack {
                    Image(systemName: "sparkles")
                    Text("Discover Species")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .green.opacity(0.5), radius: 10)
            }
            .padding(.horizontal, 40)
        }
        .padding(.vertical, 40)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .padding(.horizontal, 20)
    }
    
    // MARK: - Photo Options View
    
    private var photoOptionsView: some View {
        VStack(spacing: 20) {
            // Species image
            if let image = UIImage(named: species.imageName) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.3), radius: 10)
            }
            
            VStack(spacing: 8) {
                Text("Capture this moment?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Photos help you remember your discoveries")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 12) {
                // Take Photo button
                Button(action: {
                    if CameraPermissionHelper.isCameraAvailable() {
                        showCamera = true
                    } else {
                        // Fallback: discover without photo
                        completeDiscovery()
                    }
                }) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("Take a Photo")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                
                // Skip Photo button
                Button(action: {
                    completeDiscovery()
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle")
                        Text("Skip Photo")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                
                // Back button
                Button(action: {
                    withAnimation {
                        showPhotoOptions = false
                    }
                }) {
                    Text("Back")
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.vertical, 8)
                }
            }
            .padding(.horizontal, 40)
        }
        .padding(.vertical, 40)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .padding(.horizontal, 20)
    }
    
    // MARK: - Complete Discovery
    
    private func completeDiscovery() {
        isDiscovering = true
        
        // Convert image to Data if captured
        let photoData: Data? = capturedImage?.jpegData(compressionQuality: 0.8)
        
        discoveryManager.discoverSpecies(species.id, photoData: photoData) { success in
            isDiscovering = false
            
            if success {
                // Trigger celebration
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    discovered = true
                }
                
                // Send discovery notification
                Task {
                    await notificationManager.sendDiscoveryNotification(
                        speciesName: species.name,
                        locationName: location.name
                    )
                }
                
                // Auto-dismiss after celebration
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Celebration View

struct CelebrationView: View {
    let species: Species
    let capturedImage: UIImage?
    @State private var scale: CGFloat = 0.5
    @State private var rotation: Double = -180
    @State private var showingConfetti = false
    
    var body: some View {
        VStack(spacing: 30) {
            ZStack {
                // Confetti particles
                if showingConfetti {
                    ForEach(0..<20, id: \.self) { index in
                        ConfettiParticle(index: index)
                    }
                }
                
                // Species image or captured photo
                if let capturedImage = capturedImage {
                    Image(uiImage: capturedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 250, height: 250)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.green, lineWidth: 6)
                        )
                        .shadow(color: .green.opacity(0.5), radius: 30)
                        .scaleEffect(scale)
                        .rotationEffect(.degrees(rotation))
                } else if let image = UIImage(named: species.imageName) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 250, height: 250)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.green, lineWidth: 6)
                        )
                        .shadow(color: .green.opacity(0.5), radius: 30)
                        .scaleEffect(scale)
                        .rotationEffect(.degrees(rotation))
                }
                
                // Checkmark + Camera badge
                VStack {
                    HStack {
                        Spacer()
                        VStack(spacing: 4) {
                            Circle()
                                .fill(.green)
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                )
                                .shadow(color: .green.opacity(0.5), radius: 10)
                                .scaleEffect(scale)
                            
                            // Camera badge if photo captured
                            if capturedImage != nil {
                                Circle()
                                    .fill(.blue)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Image(systemName: "camera.fill")
                                            .font(.callout)
                                            .foregroundColor(.white)
                                    )
                                    .shadow(color: .blue.opacity(0.5), radius: 8)
                                    .scaleEffect(scale)
                            }
                        }
                    }
                    Spacer()
                }
                .frame(width: 250, height: 250)
            }
            
            VStack(spacing: 8) {
                Text("🎉 Discovery Complete!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(species.name)
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.9))
                
                if capturedImage != nil {
                    Text("Photo saved to collection")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                } else {
                    Text("Added to your collection")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .padding(.vertical, 40)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .padding(.horizontal, 20)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
                rotation = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showingConfetti = true
            }
        }
    }
}

// MARK: - Confetti Particle

struct ConfettiParticle: View {
    let index: Int
    @State private var yOffset: CGFloat = -50
    @State private var xOffset: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1
    
    var body: some View {
        Rectangle()
            .fill(randomColor)
            .frame(width: 10, height: 10)
            .rotationEffect(.degrees(rotation))
            .opacity(opacity)
            .offset(x: xOffset, y: yOffset)
            .onAppear {
                let randomX = CGFloat.random(in: -150...150)
                let randomY = CGFloat.random(in: 200...400)
                let randomRotation = Double.random(in: 0...720)
                
                withAnimation(.easeOut(duration: Double.random(in: 1.5...2.5))) {
                    xOffset = randomX
                    yOffset = randomY
                    rotation = randomRotation
                    opacity = 0
                }
            }
    }
    
    var randomColor: Color {
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
        return colors[index % colors.count]
    }
}

#Preview {
    DiscoveryView(
        species: Species.preview,
        location: Location.preview
    )
}
