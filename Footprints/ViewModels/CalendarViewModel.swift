//
//  CalendarViewModel.swift
//  Footprints
//
//  View model for calendar functionality
//

import Foundation
import CoreData
import Combine

class CalendarViewModel: ObservableObject {
    @Published var currentMonth: Date = Date()
    @Published var selectedDate: Date?
    @Published var monthWalks: [Date: [Walk]] = [:]
    @Published var walksForSelectedDate: [Walk] = []
    
    private var viewContext: NSManagedObjectContext {
        PersistenceController.shared.container.viewContext
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadMonthData()
        
        // React to month changes
        $currentMonth
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.loadMonthData()
            }
            .store(in: &cancellables)
        
        // React to date selection
        $selectedDate
            .compactMap { $0 }
            .sink { [weak self] date in
                self?.loadWalksForDate(date)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Data Loading
    
    func loadMonthData() {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else { return }
        
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
            
            monthWalks = result
        } catch {
            print("Error fetching monthly walks: \(error)")
        }
    }
    
    func loadWalksForDate(_ date: Date) {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: date)
        walksForSelectedDate = monthWalks[dayStart] ?? []
    }
    
    // MARK: - Navigation
    
    func goToPreviousMonth() {
        let calendar = Calendar.current
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    func goToNextMonth() {
        let calendar = Calendar.current
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    func goToToday() {
        currentMonth = Date()
        selectedDate = Date()
    }
    
    // MARK: - Calendar Helpers
    
    var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    var daysInMonth: [Date] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else {
            return []
        }
        
        // Get the weekday of the first day (0 = Sunday)
        let firstWeekday = calendar.component(.weekday, from: monthStart) - 1
        
        // Get days from previous month to fill the first week
        var days: [Date] = []
        
        if firstWeekday > 0 {
            for i in stride(from: firstWeekday, to: 0, by: -1) {
                if let date = calendar.date(byAdding: .day, value: -i, to: monthStart) {
                    days.append(date)
                }
            }
        }
        
        // Add all days in the current month
        var currentDate = monthStart
        while currentDate < monthInterval.end {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        // Fill remaining days to complete the last week
        let remainingDays = 7 - (days.count % 7)
        if remainingDays < 7 {
            for i in 0..<remainingDays {
                if let date = calendar.date(byAdding: .day, value: i, to: currentDate) {
                    days.append(date)
                }
            }
        }
        
        return days
    }
    
    func isCurrentMonth(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
    }
    
    func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
    
    func isSelected(_ date: Date) -> Bool {
        guard let selected = selectedDate else { return false }
        return Calendar.current.isDate(date, inSameDayAs: selected)
    }
    
    func hasWalks(on date: Date) -> Bool {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: date)
        return monthWalks[dayStart] != nil
    }
    
    func walkCount(on date: Date) -> Int {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: date)
        return monthWalks[dayStart]?.count ?? 0
    }
    
    func totalDistance(on date: Date) -> Double {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: date)
        let walks = monthWalks[dayStart] ?? []
        return walks.reduce(0) { $0 + $1.distance }
    }
    
    func intensityLevel(on date: Date) -> Int {
        let distance = totalDistance(on: date) / 1000 // in km
        if distance == 0 { return 0 }
        if distance < 2 { return 1 }
        if distance < 5 { return 2 }
        return 3
    }
}

// MARK: - Week Day Names

extension CalendarViewModel {
    static let weekDayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    static let shortWeekDayNames = ["S", "M", "T", "W", "T", "F", "S"]
}


