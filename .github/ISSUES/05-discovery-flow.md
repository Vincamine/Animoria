# [Phase 2.1] Discovery Flow & Species Collection

## Overview
Implement the core discovery mechanic: species become discoverable only when user is on-site at their location.

## Tasks
- [ ] Add "discovered" state to Species model
- [ ] Create Core Data entity for SpeciesDiscovery (id, speciesId, discoveredAt, photoData)
- [ ] Add DiscoveryManager service to handle discovery logic
- [ ] Show "locked" vs "unlocked" species in Collection tab
- [ ] Implement discovery button on location detail (only enabled on-site)
- [ ] Add discovery animation/celebration when species unlocked
- [ ] Show discovery count: "3/7 discovered at Channel Islands"
- [ ] Persist discoveries across app launches

## Acceptance Criteria
- Species locked/grayed out until discovered
- Discovery only possible when user is on-site (geofence)
- Tapping species at location → "Discover" button if on-site
- Discovery triggers animation + notification
- Collection tab shows discovered vs total count
- Discoveries persist in Core Data
- Works offline

## Files to Create/Modify
```
Animoria/
├── Models/
│   ├── SpeciesDiscovery.swift (NEW - Core Data entity)
│   └── Animoria.xcdatamodeld (NEW - Core Data schema)
├── Services/
│   └── DiscoveryManager.swift (NEW)
├── Views/
│   ├── DiscoveryView.swift (NEW - discovery flow)
│   ├── CollectionView.swift (MODIFY - show discovered)
│   └── LocationDetailView.swift (MODIFY - add discover button)
```

## Labels
`phase-2` `discovery` `core-data`
