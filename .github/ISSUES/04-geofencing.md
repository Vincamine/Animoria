# [Phase 1.4] Geofencing & Proximity Alerts

## Overview
Set up geofence regions to detect when user enters/exits supported park locations.

## Tasks
- [ ] Add `NSLocationAlwaysAndWhenInUseUsageDescription` to Info.plist
- [ ] Register CLCircularRegion for each location (500m-1km radius)
- [ ] Handle `didEnterRegion` callback
- [ ] Request notification permissions
- [ ] Send local notification on region entry: "You're at [Location]! X species to discover"
- [ ] Update UI when user is "on-site" vs "away"
- [ ] Handle maximum 20 geofence limit (prioritize nearest)

## Acceptance Criteria
- Geofences registered for all locations (up to 20)
- Local notification fires when entering a park
- App UI shows "You're here!" badge when on-site
- Species become "discoverable" only when on-site
- Works in background
- Battery-efficient

## Files to Create/Modify
```
Animoria/
├── Services/
│   ├── LocationManager.swift (MODIFY - add geofencing)
│   └── NotificationManager.swift (NEW)
├── Info.plist (MODIFY - background modes)
└── Views/
    └── LocationCard.swift (MODIFY - on-site indicator)
```

## Labels
`phase-1` `geofencing` `notifications`
