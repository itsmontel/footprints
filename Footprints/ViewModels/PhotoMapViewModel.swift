//
//  PhotoMapViewModel.swift
//  Footprints
//
//  View model for the Photo Map tab with photo clustering
//

import Foundation
import CoreData
import MapKit
import CoreLocation
import Combine
import SwiftUI

class PhotoMapViewModel: ObservableObject {
    
    enum TimeFilter: String, CaseIterable {
        case allTime = "All Time"
        case thisYear = "This Year"
        case thisMonth = "This Month"
        case thisWeek = "This Week"
    }
    
    @Published var photoAnnotations: [PhotoAnnotationData] = []
    @Published var selectedFilter: TimeFilter = .allTime
    @Published var selectedPhoto: PhotoAnnotationData?
    @Published var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @Published var totalPhotos: Int = 0
    @Published var totalWalks: Int = 0
    
    private var viewContext: NSManagedObjectContext {
        PersistenceController.shared.container.viewContext
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // React to filter changes
        $selectedFilter
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.loadPhotoAnnotations()
            }
            .store(in: &cancellables)
    }
    
    func loadPhotoAnnotations() {
        let walks = fetchFilteredWalks()
        var annotations: [PhotoAnnotationData] = []
        var walkSet = Set<UUID>()
        
        for walk in walks {
            guard let walkId = walk.id else { continue }
            
            let photoLocations = walk.photoLocations
            
            for location in photoLocations {
                let annotation = PhotoAnnotationData(
                    id: location.id,
                    coordinate: location.coordinate,
                    photoURL: location.photoURL,
                    walkId: walkId,
                    walkDate: walk.date ?? Date(),
                    timestamp: location.timestamp
                )
                annotations.append(annotation)
                walkSet.insert(walkId)
            }
        }
        
        photoAnnotations = annotations
        totalPhotos = annotations.count
        totalWalks = walkSet.count
        
        // Update map region to show all photos
        if !annotations.isEmpty {
            updateMapRegionToFitAnnotations()
        }
    }
    
    private func fetchFilteredWalks() -> [Walk] {
        let request: NSFetchRequest<Walk> = Walk.fetchRequest()
        request.predicate = NSPredicate(format: "photoGPSData != nil")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Walk.date, ascending: false)]
        
        // Apply time filter
        var predicates: [NSPredicate] = [NSPredicate(format: "photoGPSData != nil")]
        
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedFilter {
        case .allTime:
            break
        case .thisYear:
            if let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now)) {
                predicates.append(NSPredicate(format: "date >= %@", startOfYear as NSDate))
            }
        case .thisMonth:
            if let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) {
                predicates.append(NSPredicate(format: "date >= %@", startOfMonth as NSDate))
            }
        case .thisWeek:
            if let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) {
                predicates.append(NSPredicate(format: "date >= %@", startOfWeek as NSDate))
            }
        }
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        do {
            let walks = try viewContext.fetch(request)
            return walks.filter { !$0.photoLocations.isEmpty }
        } catch {
            print("Error fetching walks with photos: \(error)")
            return []
        }
    }
    
    private func updateMapRegionToFitAnnotations() {
        guard !photoAnnotations.isEmpty else { return }
        
        let latitudes = photoAnnotations.map { $0.coordinate.latitude }
        let longitudes = photoAnnotations.map { $0.coordinate.longitude }
        
        guard let minLat = latitudes.min(),
              let maxLat = latitudes.max(),
              let minLon = longitudes.min(),
              let maxLon = longitudes.max() else { return }
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: max(0.01, (maxLat - minLat) * 1.5),
            longitudeDelta: max(0.01, (maxLon - minLon) * 1.5)
        )
        
        mapRegion = MKCoordinateRegion(center: center, span: span)
    }
    
    func fetchWalk(for id: UUID) -> Walk? {
        let request: NSFetchRequest<Walk> = Walk.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            return try viewContext.fetch(request).first
        } catch {
            print("Error fetching walk: \(error)")
            return nil
        }
    }
    
    func centerOnPhoto(_ photo: PhotoAnnotationData) {
        withAnimation(.easeInOut(duration: 0.3)) {
            mapRegion = MKCoordinateRegion(
                center: photo.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            )
        }
    }
}

// MARK: - Photo Annotation Data

struct PhotoAnnotationData: Identifiable, Hashable {
    let id: UUID
    let coordinate: CLLocationCoordinate2D
    let photoURL: String
    let walkId: UUID
    let walkDate: Date
    let timestamp: Date
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: walkDate)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: PhotoAnnotationData, rhs: PhotoAnnotationData) -> Bool {
        lhs.id == rhs.id
    }
}

