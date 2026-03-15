//
//  Location.swift
//  Animoria
//
//  Phase 1.1 - Data Architecture
//

import SwiftUI
import CoreLocation

struct Location: Identifiable, Codable {
    let id: String
    let name: String
    let subtitle: String
    let imageName: String
    let colorHex: String
    let coordinate: Coordinate
    let radius: Double // geofence radius in meters
    let speciesIds: [String]
    
    struct Coordinate: Codable {
        let latitude: Double
        let longitude: Double
        
        var clLocation: CLLocationCoordinate2D {
            CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
    
    // Computed property for SwiftUI color
    var color: Color {
        Color(hex: colorHex) ?? .blue
    }
    
    // Distance from user (set by LocationManager)
    var distanceFromUser: CLLocationDistance?
    
    // Whether user is currently inside this location's geofence
    var isUserOnSite: Bool = false
}

// MARK: - Color Extension for Hex
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let r, g, b: Double
        switch hexSanitized.count {
        case 6:
            r = Double((rgb & 0xFF0000) >> 16) / 255.0
            g = Double((rgb & 0x00FF00) >> 8) / 255.0
            b = Double(rgb & 0x0000FF) / 255.0
        default:
            return nil
        }
        
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Sample/Preview Data
extension Location {
    static let preview = Location(
        id: "channel-islands",
        name: "Channel Islands",
        subtitle: "Ventura, California",
        imageName: "ChannelIslandsLight",
        colorHex: "#D7F2FF",
        coordinate: Coordinate(latitude: 34.0069, longitude: -119.7785),
        radius: 1000,
        speciesIds: ["island-fox", "island-deer-mouse", "gopher-snake", "island-night-lizard"]
    )
}
