//
//  Achievement.swift
//  Animoria
//
//  Phase 2.4 - Achievement System
//

import Foundation

struct Achievement: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let iconName: String
    let condition: AchievementCondition
    let points: Int
    
    enum AchievementCondition: Codable, Equatable {
        case firstDiscovery
        case discoverCount(Int)
        case completeLocation(String)
        case photoCount(Int)
        case arViewCount(Int)
        case visitLocations(Int)
        case earlyBird // discover before 8am
        case nightOwl // discover after 10pm
        case explorer // visit all locations
        case collector // discover all species
        
        enum CodingKeys: String, CodingKey {
            case type
            case value
            case locationId
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)
            
            switch type {
            case "firstDiscovery":
                self = .firstDiscovery
            case "discoverCount":
                let count = try container.decode(Int.self, forKey: .value)
                self = .discoverCount(count)
            case "completeLocation":
                let locationId = try container.decode(String.self, forKey: .locationId)
                self = .completeLocation(locationId)
            case "photoCount":
                let count = try container.decode(Int.self, forKey: .value)
                self = .photoCount(count)
            case "arViewCount":
                let count = try container.decode(Int.self, forKey: .value)
                self = .arViewCount(count)
            case "visitLocations":
                let count = try container.decode(Int.self, forKey: .value)
                self = .visitLocations(count)
            case "earlyBird":
                self = .earlyBird
            case "nightOwl":
                self = .nightOwl
            case "explorer":
                self = .explorer
            case "collector":
                self = .collector
            default:
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(codingPath: decoder.codingPath,
                                         debugDescription: "Unknown achievement type")
                )
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            switch self {
            case .firstDiscovery:
                try container.encode("firstDiscovery", forKey: .type)
            case .discoverCount(let count):
                try container.encode("discoverCount", forKey: .type)
                try container.encode(count, forKey: .value)
            case .completeLocation(let locationId):
                try container.encode("completeLocation", forKey: .type)
                try container.encode(locationId, forKey: .locationId)
            case .photoCount(let count):
                try container.encode("photoCount", forKey: .type)
                try container.encode(count, forKey: .value)
            case .arViewCount(let count):
                try container.encode("arViewCount", forKey: .type)
                try container.encode(count, forKey: .value)
            case .visitLocations(let count):
                try container.encode("visitLocations", forKey: .type)
                try container.encode(count, forKey: .value)
            case .earlyBird:
                try container.encode("earlyBird", forKey: .type)
            case .nightOwl:
                try container.encode("nightOwl", forKey: .type)
            case .explorer:
                try container.encode("explorer", forKey: .type)
            case .collector:
                try container.encode("collector", forKey: .type)
            }
        }
    }
}

// MARK: - Achievement Progress

struct AchievementProgress: Codable {
    let achievementId: String
    var unlockedAt: Date?
    var currentProgress: Int
    var isUnlocked: Bool { unlockedAt != nil }
    
    init(achievementId: String, currentProgress: Int = 0, unlockedAt: Date? = nil) {
        self.achievementId = achievementId
        self.currentProgress = currentProgress
        self.unlockedAt = unlockedAt
    }
}
