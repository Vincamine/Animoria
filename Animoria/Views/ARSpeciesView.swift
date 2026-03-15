//
//  ARSpeciesView.swift
//  Animoria
//
//  Phase 2.3 - AR Species Viewer with RealityKit
//

import SwiftUI
import RealityKit
import ARKit

struct ARSpeciesView: View {
    let species: Species
    @Environment(\.dismiss) var dismiss
    @StateObject private var arViewModel = ARViewModel()
    @StateObject private var achievementManager = AchievementManager.shared
    
    @State private var showInstructions = true
    @State private var showControls = true
    @State private var capturedImage: UIImage?
    @State private var showingPhotoSaved = false
    
    var body: some View {
        ZStack {
            // AR View
            ARViewContainer(viewModel: arViewModel, species: species)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture { location in
                    if !arViewModel.modelPlaced {
                        arViewModel.placeModel(at: location)
                    }
                    
                    // Hide instructions after placement
                    if arViewModel.modelPlaced && showInstructions {
                        withAnimation {
                            showInstructions = false
                        }
                    }
                }
            
            // Instructions overlay
            if showInstructions {
                VStack {
                    Spacer()
                    instructionsView
                        .padding()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            
            // Top controls
            VStack {
                topControlsView
                Spacer()
            }
            
            // Bottom controls
            if arViewModel.modelPlaced && showControls {
                VStack {
                    Spacer()
                    bottomControlsView
                        .padding()
                }
            }
            
            // Photo saved confirmation
            if showingPhotoSaved, let image = capturedImage {
                photoSavedOverlay(image: image)
            }
        }
        .statusBar(hidden: true)
        .onAppear {
            // Record AR view for achievements
            achievementManager.recordARView()
            
            // Check achievements
            achievementManager.checkAchievements(
                discoveryManager: DiscoveryManager.shared,
                dataManager: DataManager.shared
            )
        }
    }
    
    // MARK: - Instructions View
    
    private var instructionsView: some View {
        VStack(spacing: 16) {
            if !arViewModel.modelPlaced {
                HStack(spacing: 12) {
                    Image(systemName: "hand.tap.fill")
                        .font(.title)
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Place \(species.name)")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("Tap on a flat surface to place the model")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }
    
    // MARK: - Top Controls
    
    private var topControlsView: some View {
        HStack {
            // Close button
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 4)
            }
            
            Spacer()
            
            // Species name
            Text(species.name)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
            
            Spacer()
            
            // Reset button
            if arViewModel.modelPlaced {
                Button(action: {
                    arViewModel.resetModel()
                    withAnimation {
                        showInstructions = true
                    }
                }) {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 4)
                }
            } else {
                // Placeholder for symmetry
                Color.clear
                    .frame(width: 40, height: 40)
            }
        }
        .padding()
    }
    
    // MARK: - Bottom Controls
    
    private var bottomControlsView: some View {
        HStack(spacing: 20) {
            // Scale controls
            VStack(spacing: 12) {
                Button(action: { arViewModel.scaleUp() }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 4)
                }
                
                Button(action: { arViewModel.scaleDown() }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 4)
                }
            }
            
            Spacer()
            
            // Capture button
            Button(action: captureARScene) {
                ZStack {
                    Circle()
                        .fill(.white)
                        .frame(width: 70, height: 70)
                        .shadow(color: .black.opacity(0.3), radius: 8)
                    
                    Circle()
                        .stroke(.white, lineWidth: 4)
                        .frame(width: 80, height: 80)
                }
            }
            
            Spacer()
            
            // Rotate controls
            VStack(spacing: 12) {
                Button(action: { arViewModel.rotateLeft() }) {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 4)
                }
                
                Button(action: { arViewModel.rotateRight() }) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 4)
                }
            }
        }
        .padding(.horizontal, 30)
    }
    
    // MARK: - Photo Saved Overlay
    
    private func photoSavedOverlay(image: UIImage) -> some View {
        ZStack {
            Color.black.opacity(0.3).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(radius: 10)
                
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.green)
                    
                    Text("AR Photo Saved!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            .padding(30)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
        .transition(.opacity)
    }
    
    // MARK: - Actions
    
    private func captureARScene() {
        if let snapshot = arViewModel.captureSnapshot() {
            capturedImage = snapshot
            
            // Save to photo library (optional)
            UIImageWriteToSavedPhotosAlbum(snapshot, nil, nil, nil)
            
            withAnimation {
                showingPhotoSaved = true
            }
            
            // Auto-hide after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showingPhotoSaved = false
                }
            }
        }
    }
}

// MARK: - AR View Container

struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var viewModel: ARViewModel
    let species: Species
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        viewModel.arView = arView
        
        // Configure AR session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        
        arView.session.run(config)
        
        // Add coaching overlay
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.session = arView.session
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        arView.addSubview(coachingOverlay)
        
        // Create model for species
        viewModel.createModel(for: species)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // Updates handled by view model
    }
}

// MARK: - AR View Model

@MainActor
class ARViewModel: ObservableObject {
    @Published var modelPlaced = false
    @Published var currentScale: Float = 1.0
    @Published var currentRotation: Float = 0.0
    
    var arView: ARView?
    private var modelEntity: ModelEntity?
    private var anchorEntity: AnchorEntity?
    
    // MARK: - Model Creation
    
    func createModel(for species: Species) {
        // Check if .usdz model exists for species
        if let modelURL = Bundle.main.url(forResource: species.id, withExtension: "usdz"),
           let modelEntity = try? ModelEntity.loadModel(contentsOf: modelURL) {
            // Use actual 3D model
            self.modelEntity = modelEntity
        } else {
            // Fallback: Create colored sphere as placeholder
            createPlaceholderModel(for: species)
        }
    }
    
    private func createPlaceholderModel(for species: Species) {
        // Create a simple sphere with species-based color
        let mesh = MeshResource.generateSphere(radius: 0.1)
        let material = SimpleMaterial(color: speciesColor(for: species), isMetallic: false)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        
        // Add simple animation
        entity.scale = [1, 1, 1]
        
        self.modelEntity = entity
    }
    
    private func speciesColor(for species: Species) -> UIColor {
        // Generate color based on species name hash
        let hash = species.id.hashValue
        let hue = CGFloat(abs(hash) % 360) / 360.0
        return UIColor(hue: hue, saturation: 0.7, brightness: 0.9, alpha: 1.0)
    }
    
    // MARK: - Placement
    
    func placeModel(at screenLocation: CGPoint) {
        guard let arView = arView, let modelEntity = modelEntity, !modelPlaced else { return }
        
        // Perform raycast to find surface
        let results = arView.raycast(from: screenLocation, allowing: .estimatedPlane, alignment: .any)
        
        guard let firstResult = results.first else { return }
        
        // Create anchor at hit location
        let anchor = AnchorEntity(world: firstResult.worldTransform)
        anchor.addChild(modelEntity)
        
        // Add to scene
        arView.scene.addAnchor(anchor)
        
        self.anchorEntity = anchor
        self.modelPlaced = true
    }
    
    // MARK: - Controls
    
    func scaleUp() {
        guard let modelEntity = modelEntity else { return }
        currentScale = min(currentScale * 1.2, 5.0)
        modelEntity.scale = [currentScale, currentScale, currentScale]
    }
    
    func scaleDown() {
        guard let modelEntity = modelEntity else { return }
        currentScale = max(currentScale / 1.2, 0.2)
        modelEntity.scale = [currentScale, currentScale, currentScale]
    }
    
    func rotateLeft() {
        guard let modelEntity = modelEntity else { return }
        currentRotation -= Float.pi / 4 // 45 degrees
        modelEntity.orientation = simd_quatf(angle: currentRotation, axis: [0, 1, 0])
    }
    
    func rotateRight() {
        guard let modelEntity = modelEntity else { return }
        currentRotation += Float.pi / 4 // 45 degrees
        modelEntity.orientation = simd_quatf(angle: currentRotation, axis: [0, 1, 0])
    }
    
    func resetModel() {
        guard let arView = arView, let anchor = anchorEntity else { return }
        
        // Remove from scene
        arView.scene.removeAnchor(anchor)
        
        // Reset state
        modelPlaced = false
        currentScale = 1.0
        currentRotation = 0.0
        anchorEntity = nil
        
        // Reset model transform
        if let modelEntity = modelEntity {
            modelEntity.scale = [1, 1, 1]
            modelEntity.orientation = simd_quatf(angle: 0, axis: [0, 1, 0])
        }
    }
    
    // MARK: - Screenshot
    
    func captureSnapshot() -> UIImage? {
        guard let arView = arView else { return nil }
        return arView.snapshot()
    }
}

#Preview {
    ARSpeciesView(species: Species.preview)
}
