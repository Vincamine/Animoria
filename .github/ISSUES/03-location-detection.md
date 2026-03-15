# [Phase 1.3] GPS Location Detection

## Overview
Integrate CoreLocation to track user's position and show distance to locations.

## Tasks
- [ ] Add CoreLocation framework
- [ ] Add `NSLocationWhenInUseUsageDescription` to Info.plist
- [ ] Create `Services/LocationManager.swift` singleton
- [ ] Request location permission on first map view
- [ ] Show user's current location on map (blue dot)
- [ ] Calculate distance from user to each location
- [ ] Display distance on location cards ("2.3 mi away")
- [ ] Handle permission denied state gracefully

## Acceptance Criteria
- App requests location permission appropriately
- User location shown on map when permitted
- Distance calculated and displayed for each location
- Works when location permission denied (just no distance shown)
- Battery-efficient (no continuous GPS when not needed)

## Files to Create/Modify
```
Animoria/
├── Services/
│   └── LocationManager.swift (NEW)
├── Info.plist (MODIFY)
└── Views/
    └── MapView.swift (MODIFY - add user location)
```

## Labels
`phase-1` `location` `permissions`
