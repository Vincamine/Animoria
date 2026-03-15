# Migration Guide: Phase 1 Structure

## Old Files to Remove/Move

Delete these files from the root (they're replaced by the new structure):

```bash
# Remove old root-level Swift files
rm AnimoriaApp.swift      # → replaced by Animoria/App/AnimoriaApp.swift
rm ContentView.swift      # → functionality split into Views/
rm Species.swift          # → replaced by Models/Species.swift + Data/species.json
rm LocationDetailView.swift  # → keep but move to Views/

# Keep these (move to proper location)
mv ARStickerView.swift Animoria/Views/
mv Assets.xcassets Animoria/Resources/
mv "Preview Content" Animoria/

# Remove macOS junk
rm .DS_Store
```

## New Structure

```
Animoria/
├── App/
│   └── AnimoriaApp.swift           ✅ NEW - App entry point
├── Models/
│   ├── Location.swift              ✅ NEW - Location model
│   └── Species.swift               ✅ NEW - Species model  
├── Views/
│   ├── MainTabView.swift           ✅ NEW - Tab navigation
│   ├── MapView.swift               ✅ NEW - Interactive map
│   ├── ARStickerView.swift         📦 MOVE from root
│   └── LocationDetailView.swift    📦 MOVE from root
├── Services/
│   ├── DataManager.swift           ✅ NEW - Data loading
│   ├── LocationManager.swift       ✅ NEW - GPS/geofencing
│   └── NotificationManager.swift   ✅ NEW - Notifications
├── Data/
│   ├── locations.json              ✅ NEW - Location data
│   └── species.json                ✅ NEW - Species data
├── Resources/
│   └── Assets.xcassets             📦 MOVE from root
├── Preview Content/                📦 MOVE from root
└── Info.plist                      ✅ NEW - Permissions
```

## Xcode Project Setup

Since there's no `.xcodeproj` file in the repo, you'll need to:

1. **Create new Xcode project:**
   - File → New → Project → iOS App
   - Product Name: `Animoria`
   - Interface: SwiftUI
   - Language: Swift

2. **Delete default files Xcode creates**

3. **Drag the `Animoria/` folder into the project**

4. **Add JSON files to bundle:**
   - Select `locations.json` and `species.json`
   - In File Inspector, check "Target Membership: Animoria"

5. **Add frameworks:**
   - MapKit (automatic with import)
   - CoreLocation (automatic with import)

6. **Update Info.plist:**
   - Copy entries from `Animoria/Info.plist` into your project's Info.plist
   - Or replace entirely

## Testing

1. Build and run on **physical device** (simulator can't test geofencing properly)
2. Grant location permission when prompted
3. Map should show California with two pins
4. Tap a pin to see preview card
5. Tap card to see location detail with species

## GitHub Issues

Create these issues on your repo (templates in `.github/ISSUES/`):
1. `[Phase 1.1] Data Architecture` 
2. `[Phase 1.2] MapKit Integration`
3. `[Phase 1.3] GPS Location Detection`
4. `[Phase 1.4] Geofencing & Proximity Alerts`

---

Questions? Open an issue!
