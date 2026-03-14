//
//  Species.swift
//  Animoria
//
//  Created by Wenxue Fang on 2/17/25.
//

import SwiftUI

struct Species: Identifiable {
    var id = UUID()
    var name: String
    var scientificName: String
    var appearance: String
    var habitat: String
    var feeding: String
    var reproduction: String
    var quickFacts: String
    var position: CGPoint
    var isFound: Bool = false
    var stickers: [Sticker] = []
    var speciesImage: String = ""
    
    var description: String {
        """
        Scientific Name: \(scientificName)
        
        Appearance: \(appearance)
        
        Habitat: \(habitat)
        
        Feeding: \(feeding)
        
        Reproduction: \(reproduction)
        
        Quick and Fun Facts: \(quickFacts)
        """
    }
}

struct Sticker: Identifiable {
    let id = UUID()
    var image: UIImage
    let date: Date
}

struct SpeciesView: View {
    @Binding var species: Species
    @State private var showingDetail = false
    let cardColor: Color
    
    var body: some View {
        Button(action: {
            showingDetail = true
        }) {
            Image(species.speciesImage)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .grayscale(species.stickers.isEmpty ? 1 : 0)
        }
        .sheet(isPresented: $showingDetail) {
            SpeciesDetailView(
                species: $species,
                isPresented: $showingDetail,
                cardColor: cardColor
            )
        }
        
    }
}

class SpeciesViewModel: ObservableObject {
    @Published var showDetail = false
}

struct SpeciesDetailView: View {
    @Binding var species: Species
    @Binding var isPresented: Bool
    @Environment(\.dismiss) var dismiss
    @State private var showImagePicker = false
    @State private var selectedTab = 0
    @State private var showingGallery = false
    @State private var isExpanded = false
    let cardColor: Color
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    
                    Picker("View Mode", selection: $selectedTab) {
                        Text("Info").tag(0)
                        Text("Gallery").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    if selectedTab == 0 {
                        infoSection
                    } else {
                        gallerySection
                    }
                }
//                    .background(Color.purple)
                    .background(
                        Color(UIColor { traitCollection in
                            traitCollection.userInterfaceStyle == .dark ?
                            UIColor(cardColor).inverted() :
                            UIColor(cardColor)
                        })
                    )
                    .cornerRadius(25)
                    .padding(.horizontal)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
        .transition(.move(edge: .bottom))
    }
    
    private var headerSection: some View {
        VStack {
            Image(species.speciesImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.white, lineWidth: 2)
                )
                .shadow(radius: 5)
                .padding(.horizontal)
            
            Text(species.name)
                .font(.system(.title, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            Text(species.scientificName)
                .font(.subheadline)
                .italic()
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
        }
        .padding(.top)
    }
    
    private var infoSection: some View {
        VStack(spacing: 20) {
            infoCard("Appearance", systemImage: "eye.fill", content: species.appearance)
            infoCard("Habitat", systemImage: "leaf.fill", content: species.habitat)
            infoCard("Feeding", systemImage: "fork.knife", content: species.feeding)
            infoCard("Reproduction", systemImage: "heart.fill", content: species.reproduction)
            infoCard("Quick and Fun Facts", systemImage: "lightbulb.fill", content: species.quickFacts)
        }
        .padding()
        .cornerRadius(25)
    }
    
    private func infoCard(_ title: String, systemImage: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: systemImage)
                    .foregroundStyle(Color(UIColor { traitCollection in
                        traitCollection.userInterfaceStyle == .dark ? .white : .black
                    }))
                Text(title)
                    .font(.headline)
                Spacer()
            }
            
            Text(content)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5)
        )
    }
    
    private var gallerySection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Gallery")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            if species.stickers.isEmpty {
                emptyGalleryView
            } else {
                photoGridView
            }
            
            addPhotoButton
        }
        .padding(.vertical)
    }
    
    private var emptyGalleryView: some View {
        VStack(spacing: 15) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)
            
            Text("No Photos Yet")
                .font(.headline)
            
            Text("Add your first photo to the gallery")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(cardColor)
        )
        .padding(.horizontal)
    }
    
    private var photoGridView: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 10) {
            ForEach(species.stickers) { sticker in
                Image(uiImage: sticker.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .clipShape(Rectangle())
                    .shadow(radius: 2)
            }
        }
        .padding(.horizontal)
    }
    
    private var addPhotoButton: some View {
        Button(action: {
            showImagePicker = true
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(cardColor)
                    .colorInvert()
                Text("Add Photo")
                    .foregroundColor(Color(red: 25/255, green: 25/255, blue: 112/255).opacity(0.9))
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(cardColor)
            )
            .padding(.horizontal)
        }

        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: Binding(
                get: { nil },
                set: { newImage in
                    guard let image = newImage else { return }
                    guard image.size.width > 0, image.size.height > 0 else {
                        print("Invalid image size")
                        return
                    }
                    
                    let shapes = [
                        randomSquare(for: image),
                        randomCircle(for: image),
                        randomHeart(for: image)
                    ]
                    guard let randomShape = shapes.randomElement() else {
                        print("Failed to get random shape")
                        return
                    }
                    autoreleasepool {
                        if let croppedImage = cropImage(image, to: randomShape) {
                            species.stickers.append(Sticker(image: croppedImage, date: Date()))
                            species.isFound = true
                        } else {
                            print("Failed to crop image")
                        }
                    }
                }
            ))
        }
    }
    
    func cropImage(_ image: UIImage, to shape: UIBezierPath) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        return renderer.image { context in
            shape.addClip()
            image.draw(at: .zero)
        }
    }
    
    private func randomSquare(for image: UIImage) -> UIBezierPath {
        let size = min(image.size.width, image.size.height)
        let centerX = image.size.width / 2
        let centerY = image.size.height / 2
        let x = centerX - size/2
        let y = centerY - size/2
        return UIBezierPath(rect: CGRect(x: x, y: y, width: size, height: size))
    }
    
    private func randomCircle(for image: UIImage) -> UIBezierPath {
        let size = min(image.size.width, image.size.height)
        let centerX = image.size.width / 2
        let centerY = image.size.height / 2
        let x = centerX - size/2
        let y = centerY - size/2
        return UIBezierPath(ovalIn: CGRect(x: x, y: y, width: size, height: size))
    }
    
    private func randomHeart(for image: UIImage) -> UIBezierPath {
        let size = min(image.size.width, image.size.height)
        let path = UIBezierPath()
        
        let offsetX = (image.size.width - size) / 2
        let offsetY = (image.size.height - size) / 2
        
        path.move(to: CGPoint(x: size/2 + offsetX, y: size + offsetY))
        path.addCurve(
            to: CGPoint(x: offsetX, y: size/4 + offsetY),
            controlPoint1: CGPoint(x: size/2 - size/4 + offsetX, y: size * 3/4 + offsetY),
            controlPoint2: CGPoint(x: offsetX, y: size/2 + offsetY)
        )
        path.addArc(
            withCenter: CGPoint(x: size/4 + offsetX, y: size/4 + offsetY),
            radius: size/4,
            startAngle: .pi,
            endAngle: 0,
            clockwise: true
        )
        path.addArc(
            withCenter: CGPoint(x: 3 * size/4 + offsetX, y: size/4 + offsetY),
            radius: size/4,
            startAngle: .pi,
            endAngle: 0,
            clockwise: true
        )
        path.addCurve(
            to: CGPoint(x: size/2 + offsetX, y: size + offsetY),
            controlPoint1: CGPoint(x: size + offsetX, y: size/2 + offsetY),
            controlPoint2: CGPoint(x: size/2 + size/4 + offsetX, y: size * 3/4 + offsetY)
        )
        path.close()
        return path
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
    }
}
extension UIColor {
    func inverted() -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: 1.0 - r, green: 1.0 - g, blue: 1.0 - b, alpha: a)
    }
}
