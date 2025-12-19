//
//  Walk+Extensions.swift
//  Footprints
//
//  CoreData Walk entity extensions with computed properties
//

import Foundation
import CoreLocation
import CoreData
import MapKit

extension Walk {
    
    // MARK: - Photo URLs Array
    
    var photoURLs: [String]? {
        get {
            guard let data = photoURLsData else { return nil }
            return try? JSONDecoder().decode([String].self, from: data)
        }
        set {
            photoURLsData = try? JSONEncoder().encode(newValue)
        }
    }
    
    // MARK: - Coordinates Array
    
    var coordinates: [CLLocationCoordinate2D] {
        get {
            guard let data = coordinatesData else { return [] }
            let coordData = (try? JSONDecoder().decode([CoordinateData].self, from: data)) ?? []
            return coordData.map { $0.coordinate }
        }
        set {
            let coordData = newValue.map { CoordinateData(latitude: $0.latitude, longitude: $0.longitude) }
            coordinatesData = try? JSONEncoder().encode(coordData)
        }
    }
    
    // MARK: - Photo Locations
    
    var photoLocations: [PhotoLocation] {
        get {
            guard let data = photoGPSData else { return [] }
            return (try? JSONDecoder().decode([PhotoLocation].self, from: data)) ?? []
        }
        set {
            photoGPSData = try? JSONEncoder().encode(newValue)
        }
    }
    
    // MARK: - Formatted Properties
    
    var formattedDistance: String {
        let km = distance / 1000
        if UserDefaults.standard.bool(forKey: "useMiles") {
            let miles = km * 0.621371
            return String(format: "%.2f mi", miles)
        }
        return String(format: "%.2f km", km)
    }
    
    var distanceValue: Double {
        let km = distance / 1000
        if UserDefaults.standard.bool(forKey: "useMiles") {
            return km * 0.621371
        }
        return km
    }
    
    var distanceUnit: String {
        UserDefaults.standard.bool(forKey: "useMiles") ? "mi" : "km"
    }
    
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%dh %02dm", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%d:%02d", minutes, seconds)
        } else {
            return String(format: "0:%02d", seconds)
        }
    }
    
    var formattedDurationLong: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)min"
        } else {
            return "\(minutes) min"
        }
    }
    
    var formattedPace: String {
        guard distance > 0 else { return "--:-- /km" }
        
        let km = distance / 1000
        let paceInSeconds = duration / km
        let paceMinutes = Int(paceInSeconds) / 60
        let paceSeconds = Int(paceInSeconds) % 60
        
        let unit = UserDefaults.standard.bool(forKey: "useMiles") ? "mi" : "km"
        return String(format: "%d:%02d /%@", paceMinutes, paceSeconds, unit)
    }
    
    var formattedDate: String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var dayOfWeek: String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    var shortDate: String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
    
    // MARK: - Map Region
    
    var mapRegion: MKCoordinateRegion {
        guard !coordinates.isEmpty else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
        
        let latitudes = coordinates.map { $0.latitude }
        let longitudes = coordinates.map { $0.longitude }
        
        let minLat = latitudes.min() ?? 0
        let maxLat = latitudes.max() ?? 0
        let minLon = longitudes.min() ?? 0
        let maxLon = longitudes.max() ?? 0
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: max(0.005, (maxLat - minLat) * 1.4),
            longitudeDelta: max(0.005, (maxLon - minLon) * 1.4)
        )
        
        return MKCoordinateRegion(center: center, span: span)
    }
    
    var startCoordinate: CLLocationCoordinate2D? {
        coordinates.first
    }
    
    var endCoordinate: CLLocationCoordinate2D? {
        coordinates.last
    }
    
    // MARK: - Helpers
    
    var hasPhotos: Bool {
        !(photoURLs?.isEmpty ?? true)
    }
    
    var photoCount: Int {
        photoURLs?.count ?? 0
    }
    
    var hasJournal: Bool {
        !(journalNote?.isEmpty ?? true)
    }
}


