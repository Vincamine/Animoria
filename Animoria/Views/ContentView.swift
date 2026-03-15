import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var showingLocationDetail = false
    @State private var selectedLocation: Location?
    
    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            
            if !dataManager.isLoaded {
                ProgressView("Loading locations...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Welcome card
                        WelcomeCardView(screenHeight: screenHeight)
                            .frame(height: screenHeight)
                        
                        // Location cards
                        ForEach(dataManager.locations) { location in
                            GeometryReader { cardGeometry in
                                let minY = cardGeometry.frame(in: .global).minY
                                let progress = -minY / screenHeight
                                let rotation = progress * 45
                                let offset = progress * 200
                                let scale = 1 - abs(progress * 0.3)
                                let opacity = 1 - abs(progress * 0.3)
                                
                                LocationCardView(
                                    location: location,
                                    screenHeight: screenHeight,
                                    showingDetail: $showingLocationDetail,
                                    selectedLocation: $selectedLocation
                                )
                                .scaleEffect(scale)
                                .opacity(opacity)
                                .rotation3DEffect(
                                    .degrees(rotation),
                                    axis: (x: 1, y: 0, z: 0)
                                )
                                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
                                .offset(y: offset)
                            }
                            .frame(height: screenHeight)
                        }
                    }
                }
                .scrollTargetBehavior(.paging)
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .fullScreenCover(item: $selectedLocation) { location in
            LocationDetailView(location: location)
                .transition(.move(edge: .bottom))
                .animation(.easeInOut, value: showingLocationDetail)
        }
    }
}

// MARK: - Welcome Card

struct WelcomeCardView: View {
    let screenHeight: CGFloat
    
    var body: some View {
        GeometryReader { cardGeometry in
            let minY = cardGeometry.frame(in: .global).minY
            let progress = -minY / screenHeight
            let rotation = progress * 45
            let offset = progress * 200
            let scale = 1 - abs(progress * 0.3)
            let opacity = 1 - abs(progress * 0.3)
            
            ZStack {
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(Color(red: 255/255, green: 250/255, blue: 213/255))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                
                VStack {
                    ZStack {
                        if let image = UIImage(named: "Demo") {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .clipped()
                        } else {
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(height: screenHeight * 0.6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .stroke(Color.clear, lineWidth: 1)
                    )
                    .padding(.horizontal, 36)
                    .padding(.top, 40)
                    
                    Spacer()
                    
                    VStack(spacing: 0) {
                        Text("Welcome to\nAnimoria")
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(Color(red: 25/255, green: 25/255, blue: 112/255))
                            .multilineTextAlignment(.center)
                        
                        Text("An app for your wild exploration")
                            .font(.largeTitle)
                            .foregroundColor(Color(red: 25/255, green: 25/255, blue: 112/255).opacity(0.9))
                    }
                    .padding(.bottom, screenHeight * 0.2)
                }
            }
            .scaleEffect(scale)
            .opacity(opacity)
            .rotation3DEffect(
                .degrees(rotation),
                axis: (x: 1, y: 0, z: 0)
            )
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
            .offset(y: offset)
        }
    }
}

// MARK: - Location Card

struct LocationCardView: View {
    let location: Location
    let screenHeight: CGFloat
    @Binding var showingDetail: Bool
    @Binding var selectedLocation: Location?
    
    var backgroundColor: Color {
        Color(hex: location.colorHex) ?? .blue.opacity(0.2)
    }
    
    var body: some View {
        Button(action: {
            selectedLocation = location
            showingDetail = true
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(backgroundColor)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                
                VStack {
                    ZStack {
                        if let image = UIImage(named: location.imageName) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .clipped()
                        } else {
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(height: screenHeight * 0.6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .stroke(Color.clear, lineWidth: 1)
                    )
                    .padding(.horizontal, 36)
                    .padding(.top, 40)
                    
                    Spacer()
                    
                    VStack(spacing: 0) {
                        Text(location.name.replacingOccurrences(of: " ", with: "\n"))
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(Color(red: 25/255, green: 25/255, blue: 112/255))
                            .multilineTextAlignment(.center)
                        
                        Text(location.subtitle)
                            .font(.largeTitle)
                            .foregroundColor(Color(red: 25/255, green: 25/255, blue: 112/255).opacity(0.9))
                    }
                    .padding(.bottom, screenHeight * 0.2)
                }
            }
        }
    }
}

// MARK: - Color Extension

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

#Preview {
    ContentView()
}
#Preview("iPhone 15 Pro") {
    ContentView()
}
#Preview("iPad Air") {
    ContentView()
}
