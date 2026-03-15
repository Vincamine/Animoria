# [Phase 2.4] Achievements & Progress Tracking

## Overview
Add achievement system to reward users for discoveries and milestones.

## Tasks
- [ ] Create Achievement model (id, name, description, icon, condition)
- [ ] Define initial achievements:
  - First Discovery
  - Complete a Location (all species)
  - Photo Enthusiast (10 photos)
  - Explorer (visit 3 locations)
  - Early Bird (discover before 8am)
- [ ] Achievement tracking service
- [ ] Achievement unlock notifications
- [ ] Achievements tab/section in Profile
- [ ] Badge display system
- [ ] Share achievement to social

## Acceptance Criteria
- Achievements unlock based on user actions
- Notification when achievement earned
- Achievements viewable in Profile
- Progress bars for incomplete achievements
- Locked vs unlocked states with icons
- Shareable achievement cards
- Persist achievement state

## Files to Create/Modify
```
Animoria/
├── Models/
│   └── Achievement.swift (NEW)
├── Services/
│   └── AchievementManager.swift (NEW)
├── Views/
│   ├── AchievementsView.swift (NEW)
│   ├── ProfileView.swift (MODIFY - add achievements)
│   └── AchievementCardView.swift (NEW - share)
├── Data/
│   └── achievements.json (NEW)
```

## Labels
`phase-2` `achievements` `gamification`
