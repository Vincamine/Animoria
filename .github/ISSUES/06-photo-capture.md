# [Phase 2.2] Camera Integration & Photo Capture

## Overview
Allow users to capture photos of species they discover and save them to their collection.

## Tasks
- [ ] Add camera permission to Info.plist (already done)
- [ ] Create CameraView with UIImagePickerController wrapper
- [ ] Add photo capture button to discovery flow
- [ ] Store photo Data in Core Data SpeciesDiscovery
- [ ] Display captured photos in collection grid
- [ ] Add photo gallery view for each species
- [ ] Option to save photo to device Photos library
- [ ] Handle camera not available (simulator, no camera device)

## Acceptance Criteria
- Camera opens during discovery flow
- Photo captured and stored with discovery record
- Captured photos visible in Collection tab
- Tapping species shows photo gallery
- Photos persist across app launches
- Graceful fallback when camera unavailable
- Option to skip photo (discover without photo)

## Files to Create/Modify
```
Animoria/
├── Views/
│   ├── CameraView.swift (NEW)
│   ├── PhotoGalleryView.swift (NEW)
│   ├── DiscoveryView.swift (MODIFY - add camera)
│   └── CollectionView.swift (MODIFY - show photos)
├── Services/
│   └── PhotoManager.swift (NEW - handle photo storage)
```

## Labels
`phase-2` `camera` `photos`
