//
//  NotificationManager.swift
//  Animoria
//
//  Phase 1.4 - Geofencing Notifications
//

import Foundation
import UserNotifications

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private init() {
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            await checkAuthorizationStatus()
            return granted
        } catch {
            print("Notification authorization error: \(error.localizedDescription)")
            return false
        }
    }
    
    func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationStatus = settings.authorizationStatus
        isAuthorized = settings.authorizationStatus == .authorized
    }
    
    // MARK: - Location Entry Notification
    
    func sendLocationEntryNotification(locationId: String) async {
        guard isAuthorized else {
            print("Notifications not authorized")
            return
        }
        
        // Get location info from DataManager
        let dataManager = DataManager.shared
        guard let location = dataManager.location(withId: locationId) else { return }
        
        let speciesCount = dataManager.species(for: locationId).count
        
        let content = UNMutableNotificationContent()
        content.title = "You're at \(location.name)! 🌿"
        content.body = "\(speciesCount) species to discover nearby. Start exploring!"
        content.sound = .default
        content.categoryIdentifier = "LOCATION_ENTRY"
        content.userInfo = ["locationId": locationId]
        
        let request = UNNotificationRequest(
            identifier: "location-entry-\(locationId)-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil // Deliver immediately
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("Sent notification for \(location.name)")
        } catch {
            print("Failed to send notification: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Discovery Notification
    
    func sendDiscoveryNotification(speciesName: String, locationName: String) async {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "New Discovery! 🎉"
        content.body = "You found a \(speciesName) at \(locationName)!"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "discovery-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )
        
        try? await UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Achievement Notification
    
    func sendAchievementNotification(achievement: Achievement) async {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Achievement Unlocked! 🏆"
        content.body = "\(achievement.name) - \(achievement.description)"
        content.sound = .default
        content.categoryIdentifier = "ACHIEVEMENT"
        content.userInfo = ["achievementId": achievement.id]
        
        let request = UNNotificationRequest(
            identifier: "achievement-\(achievement.id)-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )
        
        try? await UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Clear Notifications
    
    func clearAllNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
