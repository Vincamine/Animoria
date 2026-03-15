import SwiftUI

struct CardItem: Identifiable {
    var id = UUID()
    var title: String
    var subtitle: String
    var color: Color
    var imageName: String
    var species: [Species]
}

struct ContentView: View {
    @State private var items: [CardItem] = [
        CardItem(
            title: "Welcome to Animoria",
            subtitle: "An app for your wild expolration",
//            color: Color(red: 0.902, green: 0.902, blue: 0.980),
//            color: Color(red: 241/255, green: 231/255, blue: 255/255),
//            color: Color(red: 255/255, green: 238/255, blue: 247/255),
//            color: Color(red: 0.902, green: 0.980, blue: 0.902),
//            color: Color(red: 177/255, green: 202/255, blue: 162/255),
            color: Color(red: 255/255, green: 250/255, blue: 213/255),
            imageName: "Demo",
            species: []
        ),
        CardItem(
            title: "Channel Islands",
            subtitle: "Ventura, California",
                        
            color: Color(red: 215/255, green: 242/255, blue: 255/255),

            imageName: "ChannelIslandsLight",
            species: [
                Species(
                    name: "Island Fox",
                    scientificName: "Urocyon littoralis",
                    appearance: "A small fox with a reddish-gray coat, black-tipped tail, and large ears.",
                    habitat: "Only found on six of the eight Channel Islands off the coast of Southern California.",
                    feeding: "Omnivorous, feeding on insects, fruits, birds, and small mammals.",
                    reproduction: "Breeds in early spring, with 2-3 pups per litter.",
                    quickFacts: "Once near gone, now strong and free, island fox, survivor of the sea.",
                    position: CGPoint(x: 0.1, y: 0.4),
                    speciesImage: "island_fox"
                ),
                Species(
                    name: "Island Deer Mouse",
                    scientificName: "Peromyscus maniculatus",
                    appearance: "A small, brownish mouse with large eyes and ears, adapted to island life.",
                    habitat: "Found on all eight Channel Islands, with each island hosting a unique subspecies.",
                    feeding: "Omnivorous, feeding on seeds, fruits, insects, and occasionally carrion.",
                    reproduction: "Breeds year-round, with females producing multiple litters of 2-5 pups.",
                    quickFacts: "Tiny traveler, swift and sly, island hunter, watchful eye.",
                    position: CGPoint(x: 0.2, y: 0.4),
                    speciesImage: "island_deer_mouse"
                ),
                Species(
                    name: "Gopher Snake",
                    scientificName: "Pituophis catenifer",
                    appearance: "A non-venomous snake with yellowish-brown scales and dark blotches along its body.",
                    habitat: "Found in a variety of habitats, including grasslands, chaparral, and coastal dunes.",
                    feeding: "Carnivorous, feeding on rodents, birds, eggs, and lizards.",
                    reproduction: "Lays eggs in the summer, with hatchlings emerging in early fall.",
                    quickFacts: "Hisses loud, but strikes no fear; a harmless guardian living near.",
                    position: CGPoint(x: 0.3, y: 0.4),
                    speciesImage: "gopher_snake"
                ),
                Species(
                    name: "Island Night Lizard",
                    scientificName: "Xantusia riversiana",
                    appearance: "A small, brownish-gray lizard with a flat body and granular scales.",
                    habitat: "Lives in rock crevices, under logs, and in dense vegetation on the Channel Islands.",
                    feeding: "Omnivorous, feeding on insects, spiders, and plant matter.",
                    reproduction: "Gives birth to live young rather than laying eggs, with 1-3 offspring per year.",
                    quickFacts: "Hidden by day, so still, so shy; nightfall wakes its watchful eye.",
                    position: CGPoint(x: 0.4, y: 0.4),
                    speciesImage: "island_night_lizard"
                ),
                
                
                                
                // Add more species as needed
            ]
        ),
        CardItem(
            title: "San Mateo Campground",
            subtitle: "San Diego County, California",
            color: Color(red: 228/255, green: 255/255, blue: 236/255),
            imageName: "SanMateoCampgroundLight",
            species: [
                
            ]
        )
    ]
    
    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach($items) { $item in
                        GeometryReader { cardGeometry in
                            let minY = cardGeometry.frame(in: .global).minY
                            let progress = -minY / screenHeight
                            let rotation = progress * 45
                            let offset = progress * 200
                            let scale = 1 - abs(progress * 0.3)
                            let opacity = 1 - abs(progress * 0.3)
                            
                            CardView(item: $item, screenHeight: screenHeight)
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
        .ignoresSafeArea(.all, edges: .bottom)
    }
}



struct CardView: View {
    @Binding var item: CardItem
    let screenHeight: CGFloat
    @State private var showingLocationDetail = false
    
    var body: some View {
        Button(action: {
            showingLocationDetail = true
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(item.color)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                
                VStack {
                    ZStack {
                        if let image = UIImage(named: item.imageName) {
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
                        Text(item.title.replacingOccurrences(of: " ", with: "\n"))
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(Color(red: 25/255, green: 25/255, blue: 112/255))
                            .multilineTextAlignment(.center)
                        
                        Text(item.subtitle)
                            .font(.largeTitle)
                            .foregroundColor(Color(red: 25/255, green: 25/255, blue: 112/255).opacity(0.9))
                    }
                    .padding(.bottom, screenHeight * 0.2)
                }
                
            }
        }
        .fullScreenCover(isPresented: $showingLocationDetail) {
            LocationDetailView(item: $item)
                .transition(.move(edge: .bottom))
                .animation(.easeInOut, value: showingLocationDetail)
        }

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
