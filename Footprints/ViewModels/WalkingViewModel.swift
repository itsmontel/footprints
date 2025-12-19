//
//  WalkingViewModel.swift
//  Footprints
//
//  Main view model for walk tracking and data management
//

import Foundation
import CoreData
import CoreLocation
import Combine
import SwiftUI

class WalkingViewModel: ObservableObject {
    // Location
    @Published var locationManager = LocationManager()
    
    // Tracking state
    @Published var isTracking = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var currentWalk: Walk?
    
    // Timer
    private var timer: Timer?
    private var startTime: Date?
    
    // Core Data
    private var viewContext: NSManagedObjectContext {
        PersistenceController.shared.container.viewContext
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Request location authorization on init
        locationManager.requestAuthorization()
    }
    
    // MARK: - Walk Tracking
    
    func startWalk() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            isTracking = true
        }
        startTime = Date()
        elapsedTime = 0
        
        // Start location tracking
        locationManager.startTracking()
        
        // Start timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let start = self.startTime else { return }
            self.elapsedTime = Date().timeIntervalSince(start)
        }
    }
    
    func finishWalk() -> Walk? {
        // Stop timer
        timer?.invalidate()
        timer = nil
        
        // Stop location tracking
        locationManager.stopTracking()
        
        // Create and save walk
        let walk = Walk(context: viewContext)
        walk.id = UUID()
        walk.date = startTime ?? Date()
        walk.duration = elapsedTime
        walk.distance = locationManager.totalDistance
        walk.coordinates = locationManager.trackedCoordinates
        
        // Calculate average pace (seconds per km)
        if walk.distance > 0 {
            let km = walk.distance / 1000
            walk.averagePace = elapsedTime / km
        }
        
        do {
            try viewContext.save()
            currentWalk = walk
        } catch {
            print("Error saving walk: \(error)")
        }
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            isTracking = false
        }
        
        return walk
    }
    
    func cancelWalk() {
        timer?.invalidate()
        timer = nil
        locationManager.stopTracking()
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            isTracking = false
        }
    }
    
    // MARK: - Formatted Time
    
    var formattedElapsedTime: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = (Int(elapsedTime) % 3600) / 60
        let seconds = Int(elapsedTime) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var currentPace: String {
        guard locationManager.totalDistance > 100 else { return "--:--" }
        
        let km = locationManager.totalDistance / 1000
        let paceInSeconds = elapsedTime / km
        let paceMinutes = Int(paceInSeconds) / 60
        let paceSeconds = Int(paceInSeconds) % 60
        
        return String(format: "%d:%02d", paceMinutes, paceSeconds)
    }
    
    // MARK: - Statistics
    
    func fetchWeeklyStats() -> (distance: Double, count: Int, duration: Double) {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
        
        let request: NSFetchRequest<Walk> = Walk.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@", startOfWeek as NSDate)
        
        do {
            let walks = try viewContext.fetch(request)
            let totalDistance = walks.reduce(0) { $0 + $1.distance }
            let totalDuration = walks.reduce(0) { $0 + $1.duration }
            return (totalDistance, walks.count, totalDuration)
        } catch {
            print("Error fetching weekly stats: \(error)")
            return (0, 0, 0)
        }
    }
    
    func fetchRecentWalks(limit: Int = 5) -> [Walk] {
        let request: NSFetchRequest<Walk> = Walk.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Walk.date, ascending: false)]
        request.fetchLimit = limit
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching recent walks: \(error)")
            return []
        }
    }
    
    func fetchAllWalks() -> [Walk] {
        let request: NSFetchRequest<Walk> = Walk.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Walk.date, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching walks: \(error)")
            return []
        }
    }
    
    func fetchWalks(for date: Date) -> [Walk] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
        
        let request: NSFetchRequest<Walk> = Walk.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Walk.date, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching walks for date: \(error)")
            return []
        }
    }
    
    func fetchWalksWithPhotos() -> [Walk] {
        let request: NSFetchRequest<Walk> = Walk.fetchRequest()
        request.predicate = NSPredicate(format: "photoURLsData != nil")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Walk.date, ascending: false)]
        
        do {
            let walks = try viewContext.fetch(request)
            return walks.filter { !($0.photoURLs?.isEmpty ?? true) }
        } catch {
            print("Error fetching walks with photos: \(error)")
            return []
        }
    }
    
    // MARK: - Calendar Data
    
    func walksForMonth(_ date: Date) -> [Date: [Walk]] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: date) else { return [:] }
        
        let request: NSFetchRequest<Walk> = Walk.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@",
                                         monthInterval.start as NSDate,
                                         monthInterval.end as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Walk.date, ascending: true)]
        
        do {
            let walks = try viewContext.fetch(request)
            var result: [Date: [Walk]] = [:]
            
            for walk in walks {
                guard let walkDate = walk.date else { continue }
                let dayStart = calendar.startOfDay(for: walkDate)
                if result[dayStart] != nil {
                    result[dayStart]?.append(walk)
                } else {
                    result[dayStart] = [walk]
                }
            }
            
            return result
        } catch {
            print("Error fetching monthly walks: \(error)")
            return [:]
        }
    }
    
    func totalDistanceForDay(_ date: Date) -> Double {
        let walks = fetchWalks(for: date)
        return walks.reduce(0) { $0 + $1.distance }
    }
    
    // MARK: - Data Management
    
    func deleteWalk(_ walk: Walk) {
        PersistenceController.shared.deleteWalk(walk)
    }
    
    func clearAllData() {
        PersistenceController.shared.clearAllData()
    }
}


