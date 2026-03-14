//
//  LocationManager.swift
//  Animoria
//
//  Phase 1.3 & 1.4 - GPS Location Detection & Geofencing
//

import Foundation
import CoreLocation
import Combine

@MainActor
class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()
    
    private let clLocationManager = CLLocationManager()
    
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var userLocation: CLLocation?
    @Published var isUpdatingLocation = false
    @Published var locationError: Error?
    
    // Geofencing
    @Published var currentlyInsideRegions: Set<String> = []
    
    private var dataManager: DataManager?
    
    override init() {
        super.init()
        clLocationManager.delegate = self
        clLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        clLocationManager.distanceFilter = 100 // Update every 100m
        authorizationStatus = clLocationManager.authorizationStatus
    }
    
    // MARK: - Setup
    
    func setDataManager(_ dataManager: DataManager) {
        self.dataManager = dataManager
    }
    
    // MARK: - Authorization
    
    func requestWhenInUseAuthorization() {
        clLocationManager.requestWhenInUseAuthorization()
    }
    
    func requestAlwaysAuthorization() {
        clLocationManager.requestAlwaysAuthorization()
    }
    
    var canUseLocation: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }
    
    var canUseGeofencing: Bool {
        authorizationStatus == .authorizedAlways
    }
    
    // MARK: - Location Updates
    
    func startUpdatingLocation() {
        guard canUseLocation else {
            requestWhenInUseAuthorization()
            return
        }
        isUpdatingLocation = true
        clLocationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        clLocationManager.stopUpdatingLocation()
        isUpdatingLocation = false
    }
    
    func requestOneTimeLocation() {
        guard canUseLocation else {
            requestWhenInUseAuthorization()
            return
        }
        clLocationManager.requestLocation()
    }
    
    // MARK: - Distance Calculation
    
    func distance(to coordinate: CLLocationCoordinate2D) -> CLLocationDistance? {
        guard let userLocation = userLocation else { return nil }
        let targetLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return userLocation.distance(from: targetLocation)
    }
    
    func formattedDistance(to coordinate: CLLocationCoordinate2D) -> String? {
        guard let distance = distance(to: coordinate) else { return nil }
        
        let miles = distance / 1609.34
        if miles < 0.1 {
            return "Nearby"
        } else if miles < 10 {
            return String(format: "%.1f mi", miles)
        } else {
            return String(format: "%.0f mi", miles)
        }
    }
    
    // MARK: - Geofencing
    
    func setupGeofences(for locations: [Location]) {
        guard canUseGeofencing else {
            print("Geofencing requires Always authorization")
            return
        }
        
        // Remove existing geofences
        for region in clLocationManager.monitoredRegions {
            clLocationManager.stopMonitoring(for: region)
        }
        
        // iOS limits to 20 geofences, prioritize by distance if needed
        let locationsToMonitor = Array(locations.prefix(20))
        
        for location in locationsToMonitor {
            let region = CLCircularRegion(
                center: location.coordinate.clLocation,
                radius: location.radius,
                identifier: location.id
            )
            region.notifyOnEntry = true
            region.notifyOnExit = true
            
            clLocationManager.startMonitoring(for: region)
        }
        
        print("Setup geofences for \(locationsToMonitor.count) locations")
    }
    
    func isUserInside(locationId: String) -> Bool {
        currentlyInsideRegions.contains(locationId)
    }
    
    // MARK: - Update DataManager
    
    private func updateDistances() {
        guard let dataManager = dataManager else { return }
        
        for location in dataManager.locations {
            let distance = self.distance(to: location.coordinate.clLocation)
            dataManager.updateDistance(for: location.id, distance: distance)
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        Task { @MainActor in
            self.userLocation = location
            self.locationError = nil
            self.updateDistances()
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.locationError = error
            print("Location error: \(error.localizedDescription)")
        }
    }
    
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
            
            if self.canUseLocation {
                self.requestOneTimeLocation()
            }
        }
    }
    
    // MARK: - Geofencing Delegate Methods
    
    nonisolated func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let circularRegion = region as? CLCircularRegion else { return }
        
        Task { @MainActor in
            let locationId = circularRegion.identifier
            self.currentlyInsideRegions.insert(locationId)
            self.dataManager?.updateOnSiteStatus(for: locationId, isOnSite: true)
            
            // Notify user
            await NotificationManager.shared.sendLocationEntryNotification(locationId: locationId)
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard let circularRegion = region as? CLCircularRegion else { return }
        
        Task { @MainActor in
            let locationId = circularRegion.identifier
            self.currentlyInsideRegions.remove(locationId)
            self.dataManager?.updateOnSiteStatus(for: locationId, isOnSite: false)
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Geofence monitoring failed: \(error.localizedDescription)")
    }
}
