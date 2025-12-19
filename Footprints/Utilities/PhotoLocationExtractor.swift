//
//  PhotoLocationExtractor.swift
//  Footprints
//
//  Utility for extracting GPS location data from photo EXIF metadata
//

import Foundation
import Photos
import CoreLocation
import UIKit

class PhotoLocationExtractor {
    
    // MARK: - Extract from PHAsset
    
    static func extractLocation(from asset: PHAsset) -> (coordinate: CLLocationCoordinate2D, timestamp: Date)? {
        guard let location = asset.location else { return nil }
        return (location.coordinate, asset.creationDate ?? Date())
    }
    
    // MARK: - Extract from Image Data
    
    static func extractLocation(from imageData: Data) -> CLLocationCoordinate2D? {
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any],
              let gpsData = properties[kCGImagePropertyGPSDictionary as String] as? [String: Any] else {
            return nil
        }
        
        guard let latitude = gpsData[kCGImagePropertyGPSLatitude as String] as? Double,
              let latitudeRef = gpsData[kCGImagePropertyGPSLatitudeRef as String] as? String,
              let longitude = gpsData[kCGImagePropertyGPSLongitude as String] as? Double,
              let longitudeRef = gpsData[kCGImagePropertyGPSLongitudeRef as String] as? String else {
            return nil
        }
        
        let lat = latitudeRef == "N" ? latitude : -latitude
        let lon = longitudeRef == "E" ? longitude : -longitude
        
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    // MARK: - Extract Timestamp from Image Data
    
    static func extractTimestamp(from imageData: Data) -> Date? {
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any] else {
            return nil
        }
        
        // Try EXIF date
        if let exifData = properties[kCGImagePropertyExifDictionary as String] as? [String: Any],
           let dateString = exifData[kCGImagePropertyExifDateTimeOriginal as String] as? String {
            return parseExifDate(dateString)
        }
        
        // Try GPS timestamp
        if let gpsData = properties[kCGImagePropertyGPSDictionary as String] as? [String: Any],
           let dateStamp = gpsData[kCGImagePropertyGPSDateStamp as String] as? String,
           let timeStamp = gpsData[kCGImagePropertyGPSTimeStamp as String] as? String {
            return parseGPSDateTime(dateStamp: dateStamp, timeStamp: timeStamp)
        }
        
        return nil
    }
    
    // MARK: - Parse Date Strings
    
    private static func parseExifDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        return formatter.date(from: dateString)
    }
    
    private static func parseGPSDateTime(dateStamp: String, timeStamp: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.date(from: "\(dateStamp) \(timeStamp)")
    }
    
    // MARK: - Batch Processing
    
    static func processPhotos(_ assets: [PHAsset], completion: @escaping ([PhotoLocation]) -> Void) {
        var locations: [PhotoLocation] = []
        let group = DispatchGroup()
        
        for asset in assets {
            group.enter()
            
            let options = PHImageRequestOptions()
            options.isSynchronous = false
            options.deliveryMode = .highQualityFormat
            
            PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { data, _, _, _ in
                defer { group.leave() }
                
                guard let data = data else { return }
                
                // Save image and get URL
                let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let photosPath = documentsPath.appendingPathComponent("WalkPhotos", isDirectory: true)
                
                try? FileManager.default.createDirectory(at: photosPath, withIntermediateDirectories: true)
                
                let fileName = "\(UUID().uuidString).jpg"
                let fileURL = photosPath.appendingPathComponent(fileName)
                
                do {
                    try data.write(to: fileURL)
                    
                    if let location = asset.location {
                        let photoLocation = PhotoLocation(
                            photoURL: fileURL.absoluteString,
                            latitude: location.coordinate.latitude,
                            longitude: location.coordinate.longitude,
                            timestamp: asset.creationDate ?? Date()
                        )
                        locations.append(photoLocation)
                    } else if let coordinate = extractLocation(from: data) {
                        let photoLocation = PhotoLocation(
                            photoURL: fileURL.absoluteString,
                            latitude: coordinate.latitude,
                            longitude: coordinate.longitude,
                            timestamp: extractTimestamp(from: data) ?? Date()
                        )
                        locations.append(photoLocation)
                    }
                } catch {
                    print("Error saving photo: \(error)")
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(locations)
        }
    }
}

// MARK: - UIImage Extension for GPS

extension UIImage {
    var hasGPSData: Bool {
        guard let imageData = jpegData(compressionQuality: 1.0) else { return false }
        return PhotoLocationExtractor.extractLocation(from: imageData) != nil
    }
}


