//
//  AchievementsView.swift
//  Animoria
//
//  Phase 2.4 - Achievement Display and Progress
//

import SwiftUI

struct AchievementsView: View {
    @StateObject private var achievementManager = AchievementManager.shared
    @StateObject private var discoveryManager = DiscoveryManager.shared
    @StateObject private var dataManager = DataManager.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedFilter: FilterType = .all
    
    enum FilterType: String, CaseIterable {
        case all = "All"
        case unlocked = "Unlocked"
        case locked = "Locked"
    }
    
    var filteredAchievements: [Achievement] {
        switch selectedFilter {
        case .all:
            return achievementManager.achievements
        case .unlocked:
            return achievementManager.unlockedAchievements()
        case .locked:
            return achievementManager.lockedAchievements()
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Stats Header
                    statsHeader
                    
                    // Filter Picker
                    Picker("Filter", selection: $selectedFilter) {
                        ForEach(FilterType.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Achievements List
                    LazyVStack(spacing: 16) {
                        ForEach(filteredAchievements) { achievement in
                            AchievementCard(achievement: achievement)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            // Refresh achievement status
            achievementManager.checkAchievements(
                discoveryManager: discoveryManager,
                dataManager: dataManager
            )
        }
    }
    
    // MARK: - Stats Header
    
    private var statsHeader: some View {
        VStack(spacing: 16) {
            // Trophy Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: .orange.opacity(0.3), radius: 10)
                
                Image(systemName: "trophy.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }
            
            // Points
            VStack(spacing: 4) {
                Text("\(achievementManager.totalPoints)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Total Points")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Progress Bar
            VStack(spacing: 8) {
                HStack {
                    Text("\(achievementManager.unlockedAchievements().count)/\(achievementManager.achievements.count) Unlocked")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(achievementManager.completionPercentage))%")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 12)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [.green, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: geometry.size.width * (achievementManager.completionPercentage / 100),
                                height: 12
                            )
                    }
                }
                .frame(height: 12)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.1), radius: 10)
        .padding(.horizontal)
    }
}

// MARK: - Achievement Card

struct AchievementCard: View {
    let achievement: Achievement
    @StateObject private var achievementManager = AchievementManager.shared
    
    var isUnlocked: Bool {
        achievementManager.isUnlocked(achievement.id)
    }
    
    var progress: AchievementProgress? {
        achievementManager.progress[achievement.id]
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(isUnlocked ? Color.green.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.iconName)
                    .font(.system(size: 28))
                    .foregroundColor(isUnlocked ? .green : .gray)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(achievement.name)
                        .font(.headline)
                        .foregroundColor(isUnlocked ? .primary : .secondary)
                    
                    Spacer()
                    
                    // Points badge
                    Text("+\(achievement.points)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(isUnlocked ? .white : .gray)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(isUnlocked ? Color.green : Color.gray.opacity(0.3))
                        .clipShape(Capsule())
                }
                
                Text(achievement.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                if isUnlocked, let progress = progress, let unlockedAt = progress.unlockedAt {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                        
                        Text("Unlocked \(unlockedAt.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    .padding(.top, 4)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isUnlocked ? Color.green : Color.clear, lineWidth: 2)
        )
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
}

// MARK: - Achievement Unlock Banner

struct AchievementUnlockBanner: View {
    let achievement: Achievement
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            // Trophy Animation
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: .orange.opacity(0.5), radius: 20)
                
                Image(systemName: "trophy.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 8) {
                Text("Achievement Unlocked!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(achievement.name)
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.9))
                
                Text(achievement.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                Text("+\(achievement.points) points")
                    .font(.headline)
                    .foregroundColor(.yellow)
                    .padding(.top, 4)
            }
            
            Button(action: { isPresented = false }) {
                Text("Awesome!")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(30)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(40)
    }
}

#Preview {
    AchievementsView()
}
