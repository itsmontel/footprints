//
//  WalkDetailViewModel.swift
//  Footprints
//
//  View model for walk detail screen with photo and journal management
//

import Foundation
import CoreData
import Photos
import UIKit
import CoreLocation

class WalkDetailViewModel: ObservableObject {
    @Published var walk: Walk
    @Published var isEditingJournal = false
    @Published var journalText: String = ""
    @Published var photos: [UIImage] = []
    @Published var isLoadingPhotos = false
    
    private var viewContext: NSManagedObjectContext {
        PersistenceController.shared.container.viewContext
    }
    
    init(walk: Walk) {
        self.walk = walk
        self.journalText = walk.journalNote ?? ""
        loadPhotos()
    }
    
    // MARK: - Journal
    
    func saveJournal() {
        walk.journalNote = journalText.trimmingCharacters(in: .whitespacesAndNewlines)
        PersistenceController.shared.saveContext()
        isEditingJournal = false
    }
    
    func cancelJournalEdit() {
        journalText = walk.journalNote ?? ""
        isEditingJournal = false
    }
    
    // MARK: - Photos
    
    func loadPhotos() {
        guard let photoURLs = walk.photoURLs, !photoURLs.isEmpty else {
            photos = []
            return
        }
        
        isLoadingPhotos = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            var loadedPhotos: [UIImage] = []
            
            for urlString in photoURLs {
                if let url = URL(string: urlString),
                   let data = try? Data(contentsOf: url),
                   let image = UIImage(data: data) {
                    loadedPhotos.append(image)
                }
            }
            
            DispatchQueue.main.async {
                self?.photos = loadedPhotos
                self?.isLoadingPhotos = false
            }
        }
    }
    
    func addPhotos(from items: [PhotoPickerItem]) async {
        var newURLs = walk.photoURLs ?? []
        var newPhotoLocations = walk.photoLocations
        
        for item in items {
            if let result = await item.saveToDocuments() {
                newURLs.append(result.url)
                
                // Create PhotoLocation if we have GPS data
                if let latitude = result.latitude, let longitude = result.longitude {
                    let photoLocation = PhotoLocation(
                        photoURL: result.url,
                        latitude: latitude,
                        longitude: longitude,
                        timestamp: result.timestamp ?? walk.date ?? Date()
                    )
                    newPhotoLocations.append(photoLocation)
                }
            }
        }
        
        walk.photoURLs = newURLs
        walk.photoLocations = newPhotoLocations
        PersistenceController.shared.saveContext()
        
        loadPhotos()
    }
    
    func deletePhoto(at index: Int) {
        guard var photoURLs = walk.photoURLs, index < photoURLs.count else { return }
        
        let urlString = photoURLs[index]
        
        // Delete file
        if let url = URL(string: urlString) {
            try? FileManager.default.removeItem(at: url)
        }
        
        // Remove from arrays
        photoURLs.remove(at: index)
        walk.photoURLs = photoURLs
        
        // Remove matching photo location
        var locations = walk.photoLocations
        locations.removeAll { $0.photoURL == urlString }
        walk.photoLocations = locations
        
        PersistenceController.shared.saveContext()
        
        if index < photos.count {
            photos.remove(at: index)
        }
    }
    
    func getPhotoURL(at index: Int) -> String? {
        walk.photoURLs?[safe: index]
    }
}

// MARK: - Photo Picker Item

struct PhotoPickerItem: Identifiable {
    let id = UUID()
    let data: Data
    let asset: PHAsset?
    
    struct SaveResult {
        let url: String
        let latitude: Double?
        let longitude: Double?
        let timestamp: Date?
    }
    
    func saveToDocuments() async -> SaveResult? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let photosPath = documentsPath.appendingPathComponent("WalkPhotos", isDirectory: true)
        
        // Create photos directory if needed
        try? FileManager.default.createDirectory(at: photosPath, withIntermediateDirectories: true)
        
        let fileName = "\(UUID().uuidString).jpg"
        let fileURL = photosPath.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            
            // Extract GPS from asset if available
            var latitude: Double?
            var longitude: Double?
            var timestamp: Date?
            
            if let asset = asset {
                if let location = asset.location {
                    latitude = location.coordinate.latitude
                    longitude = location.coordinate.longitude
                }
                timestamp = asset.creationDate
            }
            
            return SaveResult(
                url: fileURL.absoluteString,
                latitude: latitude,
                longitude: longitude,
                timestamp: timestamp
            )
        } catch {
            print("Error saving photo: \(error)")
            return nil
        }
    }
}

// Safe array access
extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}


