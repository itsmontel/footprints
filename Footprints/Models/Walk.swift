//
//  Walk.swift
//  Footprints
//
//  CoreData Walk entity class
//

import Foundation
import CoreData

@objc(Walk)
public class Walk: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Walk> {
        return NSFetchRequest<Walk>(entityName: "Walk")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var distance: Double
    @NSManaged public var duration: Double
    @NSManaged public var averagePace: Double
    @NSManaged public var coordinatesData: Data?
    @NSManaged public var photoURLsData: Data?
    @NSManaged public var photoGPSData: Data?
    @NSManaged public var journalNote: String?
}

extension Walk: Identifiable {
    
}
