//
//  AchievementManager.swift
//  Animoria
//
//  Phase 2.4 - Achievement Tracking and Unlocking
//

import Foundation
import Combine

@MainActor
class AchievementManager: ObservableObject {
    static let shared = AchievementManager()
    
    @Published private(set) var achievements: [Achievement] = []
    @Published private(set) var progress: [String: AchievementProgress] = [:]
    @Published private(set) var isLoaded = false
    @Published var recentlyUnlocked: Achievement?
    
    // Statistics
    @Published private(set) var arViewCount: Int = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        Task {
            await loadAchievements()
            await loadProgress()
        }
    }
    
    // MARK: - Load Data
    
    func loadAchievements() async {
        if let url = Bundle.main.url(forResource: "achievements", withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([Achievement].self, from: data) {
                self.achievements = decoded
                print("✅ Loaded \(decoded.count) achievements")
            }
        }
        
        // Initialize progress for all achievements
        for achievement in achievements {
            if progress[achievement.id] == nil {
                progress[achievement.id] = AchievementProgress(achievementId: achievement.id)
            }
        }
        
        isLoaded = true
    }
    
    func loadProgress() async {
        // Load from UserDefaults
        if let data = UserDefaults.standard.data(forKey: "achievementProgress"),
           let decoded = try? JSONDecoder().decode([String: AchievementProgress].self, from: data) {
            self.progress = decoded
        }
        
        // Load stats
        arViewCount = UserDefaults.standard.integer(forKey: "arViewCount")
    }
    
    func saveProgress() {
        if let encoded = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(encoded, forKey: "achievementProgress")
        }
        UserDefaults.standard.set(arViewCount, forKey: "arViewCount")
    }
    
    // MARK: - Achievement Status
    
    func isUnlocked(_ achievementId: String) -> Bool {
        progress[achievementId]?.isUnlocked ?? false
    }
    
    func unlockedAchievements() -> [Achievement] {
        achievements.filter { isUnlocked($0.id) }
    }
    
    func lockedAchievements() -> [Achievement] {
        achievements.filter { !isUnlocked($0.id) }
    }
    
    var totalPoints: Int {
        unlockedAchievements().reduce(0) { $0 + $1.points }
    }
    
    var totalPossiblePoints: Int {
        achievements.reduce(0) { $0 + $1.points }
    }
    
    var completionPercentage: Double {
        guard !achievements.isEmpty else { return 0 }
        return Double(unlockedAchievements().count) / Double(achievements.count) * 100
    }
    
    // MARK: - Check Achievements
    
    func checkAchievements(
        discoveryManager: DiscoveryManager,
        dataManager: DataManager
    ) {
        let discoveries = discoveryManager.discoveries.values
        let totalDiscoveries = discoveries.count
        let photosCount = discoveries.filter { $0.photoData != nil }.count
        
        // Get visited locations
        let visitedLocations = dataManager.locations.filter { location in
            discoveryManager.discoveredCount(for: location.id, dataManager: dataManager) > 0
        }
        
        for achievement in achievements {
            guard !isUnlocked(achievement.id) else { continue }
            
            let shouldUnlock = checkCondition(
                achievement.condition,
                totalDiscoveries: totalDiscoveries,
                photosCount: photosCount,
                visitedCount: visitedLocations.count,
                discoveryManager: discoveryManager,
                dataManager: dataManager
            )
            
            if shouldUnlock {
                unlockAchievement(achievement.id)
            }
        }
    }
    
    private func checkCondition(
        _ condition: Achievement.AchievementCondition,
        totalDiscoveries: Int,
        photosCount: Int,
        visitedCount: Int,
        discoveryManager: DiscoveryManager,
        dataManager: DataManager
    ) -> Bool {
        switch condition {
        case .firstDiscovery:
            return totalDiscoveries >= 1
            
        case .discoverCount(let required):
            return totalDiscoveries >= required
            
        case .completeLocation(let locationId):
            let totalAtLocation = discoveryManager.totalCount(for: locationId, dataManager: dataManager)
            let discoveredAtLocation = discoveryManager.discoveredCount(for: locationId, dataManager: dataManager)
            return discoveredAtLocation >= totalAtLocation && totalAtLocation > 0
            
        case .photoCount(let required):
            return photosCount >= required
            
        case .arViewCount(let required):
            return arViewCount >= required
            
        case .visitLocations(let required):
            return visitedCount >= required
            
        case .earlyBird:
            // Check if any discovery was made before 8am
            return discoveryManager.discoveries.values.contains { discovery in
                let hour = Calendar.current.component(.hour, from: discovery.discoveredAt)
                return hour < 8
            }
            
        case .nightOwl:
            // Check if any discovery was made after 10pm
            return discoveryManager.discoveries.values.contains { discovery in
                let hour = Calendar.current.component(.hour, from: discovery.discoveredAt)
                return hour >= 22
            }
            
        case .explorer:
            return visitedCount >= dataManager.locations.count
            
        case .collector:
            return totalDiscoveries >= dataManager.species.count
        }
    }
    
    // MARK: - Unlock Achievement
    
    func unlockAchievement(_ achievementId: String) {
        guard var achievementProgress = progress[achievementId],
              !achievementProgress.isUnlocked else { return }
        
        achievementProgress.unlockedAt = Date()
        progress[achievementId] = achievementProgress
        
        // Find achievement
        if let achievement = achievements.first(where: { $0.id == achievementId }) {
            recentlyUnlocked = achievement
            
            // Send notification
            Task {
                await NotificationManager.shared.sendAchievementNotification(achievement: achievement)
            }
            
            // Auto-clear after showing
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
                if recentlyUnlocked?.id == achievementId {
                    recentlyUnlocked = nil
                }
            }
        }
        
        saveProgress()
        print("🏆 Unlocked achievement: \(achievementId)")
    }
    
    // MARK: - Track Actions
    
    func recordARView() {
        arViewCount += 1
        saveProgress()
    }
    
    // MARK: - Reset (for testing)
    
    func resetAllProgress() {
        for id in progress.keys {
            progress[id] = AchievementProgress(achievementId: id)
        }
        arViewCount = 0
        saveProgress()
        recentlyUnlocked = nil
        print("🔄 Reset all achievement progress")
    }
}
