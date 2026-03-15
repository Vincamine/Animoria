# [Phase 2.3] AR Species Viewer

## Overview
Add AR mode to view 3D models of species in the real world using ARKit.

## Tasks
- [ ] Add ARKit framework
- [ ] Create 3D models or download open-source animal models
- [ ] Implement ARView for placing species in real world
- [ ] Add AR button to species detail view
- [ ] Surface detection for model placement
- [ ] Pinch to scale, rotate gestures
- [ ] Capture AR screenshot
- [ ] Handle AR not available (older devices)

## Acceptance Criteria
- AR mode launches from species detail
- Species 3D model appears in camera view
- Model places on detected surfaces
- User can scale and rotate model
- AR screenshot saves to gallery
- Graceful message on non-AR devices
- Works for discovered species only (or preview mode)

## Files to Create/Modify
```
Animoria/
├── Views/
│   ├── ARSpeciesView.swift (NEW)
│   ├── SpeciesDetailView.swift (MODIFY - add AR button)
│   └── ARStickerView.swift (MODIFY/REPLACE)
├── Models/
│   └── 3D Models/ (NEW - .usdz files)
```

## Labels
`phase-2` `ar` `3d`
