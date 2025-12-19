//
//  LocationManager.swift
//  Footprints
//
//  GPS location tracking manager using CoreLocation
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationError: Error?
    
    // Tracking state
    @Published var isTracking = false
    @Published var trackedCoordinates: [CLLocationCoordinate2D] = []
    @Published var totalDistance: Double = 0 // in meters
    
    private var lastLocation: CLLocation?
    private let minimumDistanceFilter: Double = 10 // meters between updates
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = minimumDistanceFilter
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        authorizationStatus = locationManager.authorizationStatus
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
    
    // MARK: - Tracking Control
    
    func startTracking() {
        trackedCoordinates = []
        totalDistance = 0
        lastLocation = nil
        isTracking = true
        locationManager.startUpdatingLocation()
    }
    
    func stopTracking() {
        isTracking = false
        locationManager.stopUpdatingLocation()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            locationError = LocationError.accessDenied
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Filter out inaccurate locations
        guard location.horizontalAccuracy >= 0 && location.horizontalAccuracy < 50 else { return }
        
        currentLocation = location
        
        if isTracking {
            // Add coordinate to tracked path
            let coordinate = location.coordinate
            
            // Calculate distance from last point
            if let last = lastLocation {
                let distance = location.distance(from: last)
                if distance >= minimumDistanceFilter {
                    trackedCoordinates.append(coordinate)
                    totalDistance += distance
                    lastLocation = location
                }
            } else {
                // First point
                trackedCoordinates.append(coordinate)
                lastLocation = location
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationError = error
        print("Location manager error: \(error.localizedDescription)")
    }
    
    // MARK: - Computed Properties
    
    var formattedDistance: String {
        let km = totalDistance / 1000
        if UserDefaults.standard.bool(forKey: "useMiles") {
            let miles = km * 0.621371
            return String(format: "%.2f mi", miles)
        }
        return String(format: "%.2f km", km)
    }
    
    var distanceInKm: Double {
        totalDistance / 1000
    }
}

// MARK: - Location Errors

enum LocationError: Error, LocalizedError {
    case accessDenied
    case locationUnavailable
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return "Location access was denied. Please enable it in Settings."
        case .locationUnavailable:
            return "Unable to determine your location."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}


