//
//  ARStickerView.swift
//  Animoria
//
//  Created by Wenxue Fang on 2/17/25.
//

import SwiftUI
import AVFoundation
import UIKit
import ARKit
import RealityKit
import AVKit

//mark for newest version
struct GrandSlamView: View {
    let foundSpecies: [Species]
    let totalSpeciesCount: Int
    @Binding var showARView: Bool
    
    private var progress: CGFloat {
        CGFloat(foundSpecies.count) / CGFloat(totalSpeciesCount)
    }
    
    var body: some View {
        if foundSpecies.count == totalSpeciesCount {
            Button {
                showARView = true
            } label: {
                VStack(spacing: 15) {
                    Canvas { context, size in
                        // Draw tree trunk
                        let trunkPath = Path { path in
                            path.move(to: CGPoint(x: size.width / 2, y: size.height))
                            path.addLine(to: CGPoint(x: size.width / 2, y: size.height * 0.6))
                        }
                        context.stroke(trunkPath, with: .color(.brown), lineWidth: 10)
                        
                        // Draw branches and leaves for each found species
                        for (index, _) in foundSpecies.enumerated() {
                            let branchLevel = CGFloat(index + 1) / CGFloat(totalSpeciesCount)
                            let yPosition = size.height * (1.0 - branchLevel * 0.7)
                            
                            // Left branch
                            let leftBranch = Path { path in
                                path.move(to: CGPoint(x: size.width / 2, y: yPosition))
                                path.addLine(to: CGPoint(x: size.width * 0.3, y: yPosition - 20))
                            }
                            
                            // Right branch
                            let rightBranch = Path { path in
                                path.move(to: CGPoint(x: size.width / 2, y: yPosition))
                                path.addLine(to: CGPoint(x: size.width * 0.7, y: yPosition - 20))
                            }
                            
                            // Draw branches
                            context.stroke(leftBranch, with: .color(.brown), lineWidth: 5)
                            context.stroke(rightBranch, with: .color(.brown), lineWidth: 5)
                            
                            // Draw leaves
                            let leftLeaf = Path { path in
                                path.addEllipse(in: CGRect(x: size.width * 0.25, y: yPosition - 30,
                                                           width: 20, height: 20))
                            }
                            let rightLeaf = Path { path in
                                path.addEllipse(in: CGRect(x: size.width * 0.65, y: yPosition - 30,
                                                           width: 20, height: 20))
                            }
                            
                            context.fill(leftLeaf, with: .color(.green))
                            context.fill(rightLeaf, with: .color(.green))
                        }
                    }
                    .frame(width: 200, height: 300)
                    
                    Text("Tap to Enter AR World!")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white.opacity(0.9))
                        .shadow(radius: 5)
                )
            }
            .transition(.scale.combined(with: .opacity))
        }
    }
}


struct ARStickerView: View {
    @Environment(\.dismiss) var dismiss
    let stickers: [Sticker]
    @StateObject private var arViewModel = ARViewModel()
    
    @State private var showAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            ARViewContainer(arViewModel: arViewModel)
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    arViewModel.setupStickers(stickers)
                }
                .alert("AR 错误", isPresented: $arViewModel.showError) {
                    Button("确定") {
                        dismiss()
                    }
                } message: {
                    Text(errorMessage)
                }
            
            // Exit Button
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }
            .padding()
            
            // Mode Selection
            VStack {
                Spacer()
                HStack(spacing: 20) {
                    ARModeButton(title: "Finger", systemImage: "hand.point.up.fill",
                                 isSelected: arViewModel.currentMode == .finger) {
                        arViewModel.currentMode = .finger
                    }
                    
                    ARModeButton(title: "Face", systemImage: "face.smiling.fill",
                                 isSelected: arViewModel.currentMode == .face) {
                        arViewModel.currentMode = .face
                    }
                    
                    ARModeButton(title: "Magic", systemImage: "sparkles",
                                 isSelected: arViewModel.currentMode == .magic) {
                        arViewModel.currentMode = .magic
                    }
                }
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(20)
                .padding(.bottom, 30)
            }
        }
    }
}


struct ARViewContainer: UIViewRepresentable {
    let arViewModel: ARViewModel
    
    func makeUIView(context: Context) -> ARView {
        let arView = arViewModel.arView
        #if targetEnvironment(simulator) || os(macOS)
            arView.environment.background = .color(.gray) // Mac 上灰色背景以区分黑屏
        #else
            arView.environment.background = .cameraFeed() // iOS 上启用相机
        #endif
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}


struct ARModeButton: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: systemImage)
                    .font(.title2)
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(isSelected ? .yellow : .white)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
        }
    }
}


class ARViewModel: ObservableObject {

    enum InteractionMode {
        case finger
        case face
        case magic
    }
    
    @Published var currentMode: InteractionMode = .finger
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    let arView: ARView
    private var stickerEntities: [ModelEntity] = []
    private var cameraFeedSession: AVCaptureSession?
    
    init() {
        self.arView = ARView(frame: .zero)
        do {
            try setupCamera()
        } catch {
            print("AR View initialization failed: \(error)")
            showError = true
            self.errorMessage = "AR 初始化失败: \(error.localizedDescription)"
        }
    }

    func setupCamera() throws {
        #if targetEnvironment(simulator)
            self.arView.environment.background = .color(.gray)
        #else
            guard ARWorldTrackingConfiguration.isSupported else {
                print("AR World Tracking not supported")
                showError = true
                errorMessage = "设备不支持 AR 功能"
                return
            }
            
            let config = ARWorldTrackingConfiguration()
            config.planeDetection = [.horizontal, .vertical]
            
            // 在主线程运行 AR 会话
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.arView.session.run(config)
            }
            
            // 设置相机会话
            let session = AVCaptureSession()
            session.beginConfiguration()
            
            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                           for: .video,
                                                           position: .back) else {
                print("Camera setup failed - no device")
                showError = true
                errorMessage = "无法访问相机"
                return
            }
            
            do {
                let deviceInput = try AVCaptureDeviceInput(device: videoDevice)
                if session.canAddInput(deviceInput) {
                    session.addInput(deviceInput)
                } else {
                    throw NSError(domain: "CameraError", code: 1, userInfo: [NSLocalizedDescriptionKey: "无法设置相机输入"])
                }
                
                session.commitConfiguration()
                self.cameraFeedSession = session
                
                // 在后台线程启动相机
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    self?.cameraFeedSession?.startRunning()
                    
                    DispatchQueue.main.async {
                        self?.arView.environment.background = .cameraFeed()
                    }
                }
                
            } catch {
                print("Camera setup failed: \(error)")
                showError = true
                errorMessage = "相机设置失败: \(error.localizedDescription)"
            }
        #endif
        
      
    }
    
    func setupStickers(_ stickers: [Sticker]) {
        #if targetEnvironment(simulator)
            arView.environment.background = .color(.gray)
        #else
            // 确保相机会话在运行
            if cameraFeedSession?.isRunning == false {
                DispatchQueue.global(qos: .userInitiated).async {
                    self.cameraFeedSession?.startRunning()
                }
            }
        #endif
        
        // 延迟添加贴纸
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            stickers.forEach { sticker in
                self.createStickerEntity(from: sticker)
            }
        }
    }
    
    

    private func createStickerEntity(from sticker: Sticker) {
        let mesh = MeshResource.generatePlane(width: 0.2, height: 0.2)
        
        do {
            let material = try MaterialGenerator.generate(from: sticker.image)
            let entity = ModelEntity(mesh: mesh)
            entity.model?.materials = [material]
            
            #if targetEnvironment(simulator)
                let anchor = AnchorEntity()
                anchor.position = [0, 0, -1]
            #else
                let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
            #endif
                        
            anchor.addChild(entity)
            arView.scene.addAnchor(anchor)
            stickerEntities.append(entity)
            
        } catch {
            print("Failed to create sticker entity: \(error)")
        }
    }
    
    deinit {
        cameraFeedSession?.stopRunning()
    }
    
    
    private func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        arView.addGestureRecognizer(tap)
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: arView)
        
        switch currentMode {
        case .finger:
            handleFingerInteraction(at: location)
        case .face:
            handleFaceInteraction()
        case .magic:
            handleMagicInteraction(at: location)
        }
    }
    
    private func handleFingerInteraction(at location: CGPoint) {
        guard let result = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .any).first,
              let closestEntity = stickerEntities.min(by: { entity1, entity2 in
                  let resultPosition = SIMD3<Float>(result.worldTransform.columns.3.x,
                                                    result.worldTransform.columns.3.y,
                                                    result.worldTransform.columns.3.z)
                  let distance1 = entity1.position.distance(to: resultPosition)
                  let distance2 = entity2.position.distance(to: resultPosition)
                  return distance1 < distance2
              }) else { return }
        
        // Bubble pop animation
        let originalScale = closestEntity.scale
        let popScale = originalScale * 1.2
        
        closestEntity.move(
            to: Transform(scale: popScale),
            relativeTo: closestEntity.parent,
            duration: 0.1
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            closestEntity.move(
                to: Transform(scale: originalScale),
                relativeTo: closestEntity.parent,
                duration: 0.1
            )
        }
    }
    
    private func handleFaceInteraction() {
        guard ARWorldTrackingConfiguration.supportsUserFaceTracking else { return }
        
        // Animate stickers towards face position
        if let faceAnchor = arView.session.currentFrame?.anchors.first(where: { $0 is ARFaceAnchor }) {
            let transform = faceAnchor.transform
            let facePosition = SIMD3<Float>(
                transform.columns.3.x,
                transform.columns.3.y,
                transform.columns.3.z
            )
            
            for entity in stickerEntities {
                let distance = entity.position.distance(to: facePosition)
                if distance < 0.3 {
                    // Stick to face
                    entity.move(
                        to: Transform(translation: facePosition),
                        relativeTo: nil,
                        duration: 0.3
                    )
                }
            }
        }
    }
    
    private func handleMagicInteraction(at location: CGPoint) {
        // Create sparkle effect and make stickers dance
        for entity in stickerEntities {
            let randomRotation = simd_quatf(angle: Float.random(in: 0...(.pi * 2)),
                                            axis: [0, 1, 0])
            
            entity.move(
                to: Transform(rotation: randomRotation),
                relativeTo: entity.parent,
                duration: 0.5
            )
        }
    }
}

extension SIMD3 where Scalar == Float {
    func distance(to other: SIMD3<Float>) -> Float {
        let dx = self.x - other.x
        let dy = self.y - other.y
        let dz = self.z - other.z
        return sqrt(dx * dx + dy * dy + dz * dz)
    }
}


enum MaterialGenerator {
    static func generate(from image: UIImage) throws -> RealityKit.Material {
        guard let cgImage = image.cgImage else {
            throw MaterialError.invalidImage
        }
        
        let texture = try TextureResource.generate(
            from: cgImage,
            options: TextureResource.CreateOptions(semantic: .color)
        )
        

        var material = SimpleMaterial()
        material.color = SimpleMaterial.BaseColor(tint: .white, texture: .init(texture))

        return material
    }
    
    enum MaterialError: Error {
        case invalidImage
    }
}

