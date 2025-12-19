//
//  WeeklyStatsCard.swift
//  Footprints
//
//  Beautiful weekly statistics card with animations
//

import SwiftUI

struct WeeklyStatsCard: View {
    let stats: (distance: Double, count: Int, duration: Double)
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("This Week")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(weekDateRange)
                        .font(.caption)
                        .foregroundColor(AppColors.textMuted)
                }
                
                Spacer()
                
                // Week indicator dots
                HStack(spacing: 4) {
                    ForEach(0..<7, id: \.self) { day in
                        Circle()
                            .fill(day <= currentDayOfWeek ? AppColors.primaryGreen : AppColors.primaryGreen.opacity(0.2))
                            .frame(width: 6, height: 6)
                    }
                }
            }
            
            Divider()
                .background(AppColors.primaryGreen.opacity(0.2))
            
            // Stats
            HStack(spacing: 0) {
                StatItem(
                    icon: "arrow.triangle.swap",
                    value: formattedDistance,
                    unit: distanceUnit,
                    label: "Distance",
                    color: AppColors.primaryGreen
                )
                
                Divider()
                    .frame(height: 50)
                    .background(AppColors.textMuted.opacity(0.3))
                
                StatItem(
                    icon: "figure.walk",
                    value: "\(stats.count)",
                    unit: stats.count == 1 ? "walk" : "walks",
                    label: "Total",
                    color: AppColors.ocean
                )
                
                Divider()
                    .frame(height: 50)
                    .background(AppColors.textMuted.opacity(0.3))
                
                StatItem(
                    icon: "clock",
                    value: formattedDuration,
                    unit: "",
                    label: "Time",
                    color: AppColors.lavender
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: AppColors.shadowGreen, radius: 15, x: 0, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.primaryGreen.opacity(0.1), lineWidth: 1)
        )
    }
    
    // MARK: - Computed Properties
    
    private var formattedDistance: String {
        let km = stats.distance / 1000
        if UserDefaults.standard.bool(forKey: "useMiles") {
            return String(format: "%.1f", km * 0.621371)
        }
        return String(format: "%.1f", km)
    }
    
    private var distanceUnit: String {
        UserDefaults.standard.bool(forKey: "useMiles") ? "mi" : "km"
    }
    
    private var formattedDuration: String {
        let hours = Int(stats.duration) / 3600
        let minutes = (Int(stats.duration) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
    
    private var currentDayOfWeek: Int {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        return weekday - 1 // 0-indexed from Sunday
    }
    
    private var weekDateRange: String {
        let calendar = Calendar.current
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())),
              let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) else {
            return ""
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: startOfWeek)) - \(formatter.string(from: endOfWeek))"
    }
}

// MARK: - Stat Item

struct StatItem: View {
    let icon: String
    let value: String
    let unit: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppColors.textMuted)
                }
            }
            
            Text(label)
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    WeeklyStatsCard(stats: (distance: 15340, count: 4, duration: 5400))
        .padding()
        .background(AppColors.meshGradient)
}


