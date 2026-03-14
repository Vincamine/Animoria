# [Phase 1.2] MapKit Integration

## Overview
Add interactive map as primary navigation showing all supported park locations.

## Tasks
- [ ] Add MapKit import
- [ ] Create `Views/MapView.swift` with MKMapView wrapper
- [ ] Display annotation pins for each location from DataManager
- [ ] Custom annotation view with location image/name
- [ ] Tap pin → navigate to LocationDetailView
- [ ] Add TabView navigation: Map | Collection | Profile
- [ ] Center map on user location (requires Phase 1.3)

## Acceptance Criteria
- Map shows all locations as pins
- Pins display location name on tap
- Tapping pin callout opens location detail
- Smooth pan/zoom
- Works on iPhone and iPad

## Files to Create/Modify
```
Animoria/
├── Views/
│   ├── MapView.swift (NEW)
│   ├── MainTabView.swift (NEW)
│   └── LocationAnnotationView.swift (NEW)
└── ContentView.swift (MODIFY - integrate with tabs)
```

## Labels
`phase-1` `maps` `navigation`
