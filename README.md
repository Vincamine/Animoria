# Animoria 🌿

An iOS app for wildlife exploration. Discover species at real-world locations with AR features.

![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![iOS](https://img.shields.io/badge/iOS-17.0+-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## Features

- 🗺️ **Interactive Map** — Explore California parks with location pins
- 📍 **GPS Integration** — See your distance to wildlife locations  
- 🔔 **Geofencing** — Get notified when you arrive at a park
- 🦊 **Species Guide** — Learn about native wildlife at each location
- 📸 **Photo Collection** — Capture and save your discoveries
- 🔮 **AR Stickers** — View species in augmented reality

## Screenshots

*Coming soon*

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Installation

1. Clone the repository
```bash
git clone https://github.com/Vincamine/Animoria.git
cd Animoria
```

2. Open in Xcode
```bash
open Animoria.xcodeproj
```

3. Build and run on a device (location features require physical device)

## Project Structure

```
Animoria/
├── App/
│   └── AnimoriaApp.swift          # App entry point
├── Models/
│   ├── Location.swift             # Location data model
│   └── Species.swift              # Species data model
├── Views/
│   ├── MainTabView.swift          # Tab navigation
│   ├── MapView.swift              # Interactive map
│   ├── LocationDetailView.swift   # Location details
│   └── ARStickerView.swift        # AR camera view
├── Services/
│   ├── DataManager.swift          # Data loading & caching
│   ├── LocationManager.swift      # GPS & geofencing
│   └── NotificationManager.swift  # Local notifications
├── Data/
│   ├── locations.json             # Location data
│   └── species.json               # Species data
└── Resources/
    └── Assets.xcassets            # Images & colors
```

## Locations

Currently supported locations:
- **Channel Islands** — Ventura, California
- **San Mateo Campground** — San Diego County, California

*More locations coming soon!*

## Contributing

Contributions welcome! Please read our contributing guidelines first.

1. Fork the repo
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Roadmap

- [x] Phase 1: Foundation (Data, Maps, GPS, Geofencing)
- [ ] Phase 2: Core Experience (Discovery flow, AR, Collection)
- [ ] Phase 3: Polish & Scale (More locations, TestFlight)
- [ ] Phase 4: App Store Launch

## License

MIT License — see [LICENSE](LICENSE) for details.

## Acknowledgments

- Wildlife data sourced from California Department of Fish & Wildlife
- Channel Islands National Park Service

---

Made with 🌿 by [@Vincamine](https://github.com/Vincamine)
