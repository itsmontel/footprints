//
//  PhotoLocation.swift
//  Footprints
//
//  Struct for storing photo GPS location data
//

import Foundation
import CoreLocation

struct PhotoLocation: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    let photoURL: String
    let latitude: Double
    let longitude: Double
    let timestamp: Date
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(photoURL: String, latitude: Double, longitude: Double, timestamp: Date = Date()) {
        self.photoURL = photoURL
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
    }
    
    init(photoURL: String, coordinate: CLLocationCoordinate2D, timestamp: Date = Date()) {
        self.photoURL = photoURL
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.timestamp = timestamp
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: PhotoLocation, rhs: PhotoLocation) -> Bool {
        lhs.id == rhs.id
    }
}

// Extension for clustering nearby photos
extension Array where Element == PhotoLocation {
    func clustered(threshold: Double = 50) -> [[PhotoLocation]] {
        guard !isEmpty else { return [] }
        
        var clusters: [[PhotoLocation]] = []
        var remaining = self
        
        while !remaining.isEmpty {
            let seed = remaining.removeFirst()
            var cluster = [seed]
            
            var i = 0
            while i < remaining.count {
                let location = remaining[i]
                let seedLocation = CLLocation(latitude: seed.latitude, longitude: seed.longitude)
                let compareLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                
                if seedLocation.distance(from: compareLocation) <= threshold {
                    cluster.append(location)
                    remaining.remove(at: i)
                } else {
                    i += 1
                }
            }
            
            clusters.append(cluster)
        }
        
        return clusters
    }
}


