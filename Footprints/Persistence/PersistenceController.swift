//
//  PersistenceController.swift
//  Footprints
//
//  CoreData persistence controller for local storage
//

import CoreData
import CoreLocation

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Footprints")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error loading Core Data: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // Preview instance for SwiftUI previews
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext
        
        // Create sample walks for preview
        for i in 0..<5 {
            let walk = Walk(context: context)
            walk.id = UUID()
            walk.date = Calendar.current.date(byAdding: .day, value: -i, to: Date()) ?? Date()
            walk.distance = Double.random(in: 1000...8000)
            walk.duration = Double.random(in: 600...3600)
            walk.averagePace = walk.duration / (walk.distance / 1000)
            
            // Add sample coordinates
            let sampleCoords = [
                CLLocationCoordinate2D(latitude: 37.7749 + Double(i) * 0.001, longitude: -122.4194),
                CLLocationCoordinate2D(latitude: 37.7759 + Double(i) * 0.001, longitude: -122.4184),
                CLLocationCoordinate2D(latitude: 37.7769 + Double(i) * 0.001, longitude: -122.4174),
                CLLocationCoordinate2D(latitude: 37.7779 + Double(i) * 0.001, longitude: -122.4164)
            ]
            walk.coordinatesData = try? JSONEncoder().encode(sampleCoords.map { CoordinateData(latitude: $0.latitude, longitude: $0.longitude) })
        }
        
        try? context.save()
        return controller
    }()
    
    // MARK: - Core Data Operations
    
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    func deleteWalk(_ walk: Walk) {
        let context = container.viewContext
        
        // Delete associated photos from file system
        if let photoURLs = walk.photoURLs {
            for urlString in photoURLs {
                if let url = URL(string: urlString) {
                    try? FileManager.default.removeItem(at: url)
                }
            }
        }
        
        context.delete(walk)
        saveContext()
    }
    
    func clearAllData() {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Walk.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try container.persistentStoreCoordinator.execute(deleteRequest, with: context)
            
            // Clear photos directory
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let photosPath = documentsPath.appendingPathComponent("WalkPhotos")
            try? FileManager.default.removeItem(at: photosPath)
            
        } catch {
            print("Error clearing data: \(error)")
        }
    }
}

// Helper struct for encoding coordinates
struct CoordinateData: Codable {
    let latitude: Double
    let longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}


