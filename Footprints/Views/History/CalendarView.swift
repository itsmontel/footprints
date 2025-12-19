//
//  CalendarView.swift
//  Footprints
//
//  Full calendar view for the History tab
//

import SwiftUI
import CoreData

struct CalendarView: View {
    @StateObject private var calendarVM = CalendarViewModel()
    let onWalkSelected: (Walk) -> Void
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Month header
                monthHeader
                
                // Calendar grid
                calendarGrid
                
                // Selected day walks
                if calendarVM.selectedDate != nil {
                    selectedDayWalks
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Month Header
    
    private var monthHeader: some View {
        HStack {
            Button(action: { calendarVM.goToPreviousMonth() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.primaryGreen)
                    .padding(12)
                    .background(
                        Circle()
                            .fill(.white)
                            .shadow(color: AppColors.shadowGreen, radius: 6, y: 3)
                    )
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                Text(calendarVM.monthTitle)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Button(action: { calendarVM.goToToday() }) {
                    Text("Today")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppColors.primaryGreen)
                }
            }
            
            Spacer()
            
            Button(action: { calendarVM.goToNextMonth() }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.primaryGreen)
                    .padding(12)
                    .background(
                        Circle()
                            .fill(.white)
                            .shadow(color: AppColors.shadowGreen, radius: 6, y: 3)
                    )
            }
        }
        .padding(.horizontal, 8)
    }
    
    // MARK: - Calendar Grid
    
    private var calendarGrid: some View {
        VStack(spacing: 12) {
            // Week day headers
            HStack(spacing: 6) {
                ForEach(CalendarViewModel.weekDayNames, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppColors.textMuted)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Day cells
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(calendarVM.daysInMonth, id: \.self) { date in
                    CalendarDayCell(
                        date: date,
                        isCurrentMonth: calendarVM.isCurrentMonth(date),
                        isToday: calendarVM.isToday(date),
                        isSelected: calendarVM.isSelected(date),
                        hasWalks: calendarVM.hasWalks(on: date),
                        walkCount: calendarVM.walkCount(on: date),
                        totalDistance: calendarVM.totalDistance(on: date),
                        intensity: calendarVM.intensityLevel(on: date)
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if calendarVM.hasWalks(on: date) {
                                calendarVM.selectedDate = date
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: AppColors.shadowGreen, radius: 12, y: 6)
        )
    }
    
    // MARK: - Selected Day Walks
    
    private var selectedDayWalks: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let date = calendarVM.selectedDate {
                HStack {
                    Text(formattedSelectedDate(date))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Text("\(calendarVM.walksForSelectedDate.count) \(calendarVM.walksForSelectedDate.count == 1 ? "walk" : "walks")")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.horizontal, 4)
            }
            
            ForEach(calendarVM.walksForSelectedDate, id: \.id) { walk in
                WalkRowView(walk: walk)
                    .onTapGesture {
                        onWalkSelected(walk)
                    }
            }
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    private func formattedSelectedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: date)
    }
}

// MARK: - Calendar Day Cell

struct CalendarDayCell: View {
    let date: Date
    let isCurrentMonth: Bool
    let isToday: Bool
    let isSelected: Bool
    let hasWalks: Bool
    let walkCount: Int
    let totalDistance: Double
    let intensity: Int
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private var distanceText: String {
        let km = totalDistance / 1000
        return String(format: "%.1f", km)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            // Day number
            Text(dayNumber)
                .font(.system(size: 16, weight: isToday ? .bold : .medium, design: .rounded))
                .foregroundColor(textColor)
            
            // Distance indicator
            if hasWalks && isCurrentMonth {
                Text("\(distanceText)km")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(distanceTextColor)
            } else {
                Text(" ")
                    .font(.system(size: 9))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isToday ? AppColors.primaryGreen : Color.clear, lineWidth: 2.5)
        )
        .overlay(
            // Walk count badge
            Group {
                if walkCount > 1 && isCurrentMonth {
                    Text("\(walkCount)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(AppColors.primaryGreen))
                        .offset(x: 14, y: -20)
                }
            }
        )
        .opacity(isCurrentMonth ? 1 : 0.3)
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return AppColors.primaryGreen.opacity(0.2)
        }
        if hasWalks && isCurrentMonth {
            switch intensity {
            case 1: return AppColors.calendarLight.opacity(0.4)
            case 2: return AppColors.calendarMedium.opacity(0.4)
            case 3: return AppColors.calendarDark.opacity(0.4)
            default: return Color.clear
            }
        }
        return Color.clear
    }
    
    private var textColor: Color {
        if isSelected {
            return AppColors.forestGreen
        }
        if isToday {
            return AppColors.primaryGreen
        }
        if hasWalks && intensity >= 2 {
            return AppColors.forestGreen
        }
        return isCurrentMonth ? AppColors.textPrimary : AppColors.textMuted
    }
    
    private var distanceTextColor: Color {
        if isSelected || intensity >= 2 {
            return AppColors.forestGreen.opacity(0.8)
        }
        return AppColors.textMuted
    }
}

#Preview {
    CalendarView(onWalkSelected: { _ in })
        .background(AppColors.meshGradient)
}

