# [Phase 1.1] Data Architecture

## Overview
Move hardcoded species/location data to JSON files and create proper data management layer.

## Tasks
- [ ] Create `Models/` folder with Swift data models
- [ ] Create `Data/locations.json` with location data
- [ ] Create `Data/species.json` with species data  
- [ ] Create `Services/DataManager.swift` to load/cache data
- [ ] Set up Core Data schema for user progress (found species, photos)
- [ ] Migrate `ContentView.swift` to use DataManager

## Acceptance Criteria
- All species/location data loaded from JSON (not hardcoded)
- DataManager provides clean API: `DataManager.shared.locations`, `DataManager.shared.species(for: locationId)`
- User's discovered species persisted in Core Data
- App works offline with cached data

## Files to Create
```
Animoria/
├── Models/
│   ├── Location.swift
│   └── Species.swift
├── Services/
│   └── DataManager.swift
├── Data/
│   ├── locations.json
│   └── species.json
└── Animoria.xcdatamodeld (Core Data)
```

## Labels
`phase-1` `data` `foundation`
