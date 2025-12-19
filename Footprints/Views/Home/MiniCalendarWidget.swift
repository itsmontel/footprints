//
//  MiniCalendarWidget.swift
//  Footprints
//
//  Compact calendar widget showing walks for the current month
//

import SwiftUI

struct MiniCalendarWidget: View {
    @StateObject private var calendarVM = CalendarViewModel()
    @State private var selectedWalk: Walk?
    @State private var showWalkDetail = false
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Button(action: { calendarVM.goToPreviousMonth() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.primaryGreen)
                        .padding(8)
                        .background(Circle().fill(AppColors.primaryGreen.opacity(0.1)))
                }
                
                Spacer()
                
                Text(calendarVM.monthTitle)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Button(action: { calendarVM.goToNextMonth() }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.primaryGreen)
                        .padding(8)
                        .background(Circle().fill(AppColors.primaryGreen.opacity(0.1)))
                }
            }
            
            // Week day headers
            HStack(spacing: 4) {
                ForEach(CalendarViewModel.shortWeekDayNames, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AppColors.textMuted)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar grid
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(calendarVM.daysInMonth, id: \.self) { date in
                    MiniCalendarDayCell(
                        date: date,
                        isCurrentMonth: calendarVM.isCurrentMonth(date),
                        isToday: calendarVM.isToday(date),
                        isSelected: calendarVM.isSelected(date),
                        hasWalks: calendarVM.hasWalks(on: date),
                        intensity: calendarVM.intensityLevel(on: date)
                    )
                    .onTapGesture {
                        if calendarVM.hasWalks(on: date) {
                            calendarVM.selectedDate = date
                        }
                    }
                }
            }
            
            // Selected date walks preview
            if calendarVM.selectedDate != nil && !calendarVM.walksForSelectedDate.isEmpty {
                Divider()
                    .padding(.vertical, 4)
                
                VStack(spacing: 8) {
                    ForEach(calendarVM.walksForSelectedDate, id: \.id) { walk in
                        MiniWalkRow(walk: walk)
                            .onTapGesture {
                                selectedWalk = walk
                                showWalkDetail = true
                            }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: AppColors.shadowGreen, radius: 12, x: 0, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.primaryGreen.opacity(0.08), lineWidth: 1)
        )
        .navigationDestination(isPresented: $showWalkDetail) {
            if let walk = selectedWalk {
                WalkDetailView(walk: walk)
            }
        }
    }
}

// MARK: - Mini Calendar Day Cell

struct MiniCalendarDayCell: View {
    let date: Date
    let isCurrentMonth: Bool
    let isToday: Bool
    let isSelected: Bool
    let hasWalks: Bool
    let intensity: Int
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 8)
                .fill(backgroundColor)
                .frame(height: 32)
            
            // Day number
            Text(dayNumber)
                .font(.system(size: 13, weight: isToday ? .bold : .medium, design: .rounded))
                .foregroundColor(textColor)
            
            // Walk indicator dot
            if hasWalks && intensity > 0 {
                Circle()
                    .fill(dotColor)
                    .frame(width: 5, height: 5)
                    .offset(y: 10)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isToday ? AppColors.primaryGreen : Color.clear, lineWidth: 2)
        )
        .opacity(isCurrentMonth ? 1 : 0.3)
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return AppColors.primaryGreen.opacity(0.2)
        }
        if hasWalks {
            switch intensity {
            case 1: return AppColors.calendarLight.opacity(0.5)
            case 2: return AppColors.calendarMedium.opacity(0.5)
            case 3: return AppColors.calendarDark.opacity(0.5)
            default: return Color.clear
            }
        }
        return Color.clear
    }
    
    private var textColor: Color {
        if isSelected || intensity >= 2 {
            return AppColors.forestGreen
        }
        if isToday {
            return AppColors.primaryGreen
        }
        return isCurrentMonth ? AppColors.textPrimary : AppColors.textMuted
    }
    
    private var dotColor: Color {
        switch intensity {
        case 1: return AppColors.calendarLight
        case 2: return AppColors.calendarMedium
        case 3: return AppColors.calendarDark
        default: return AppColors.primaryGreen
        }
    }
}

// MARK: - Mini Walk Row

struct MiniWalkRow: View {
    let walk: Walk
    
    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(AppColors.primaryGreen)
                .frame(width: 8, height: 8)
            
            Text(timeString)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
            
            Text(walk.formattedDistance)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
            
            Text(walk.formattedDurationLong)
                .font(.system(size: 12))
                .foregroundColor(AppColors.textMuted)
            
            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(AppColors.textMuted)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(AppColors.softBackground)
        )
    }
    
    private var timeString: String {
        guard let date = walk.date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

#Preview {
    MiniCalendarWidget()
        .padding()
        .background(AppColors.meshGradient)
}


