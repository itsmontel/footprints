//
//  ColorScheme.swift
//  Footprints
//
//  Beautiful green color scheme for the app
//

import SwiftUI

struct AppColors {
    // Primary greens
    static let primaryGreen = Color(hex: "34C759")
    static let forestGreen = Color(hex: "228B22")
    static let mintGreen = Color(hex: "98FB98")
    static let emeraldGreen = Color(hex: "50C878")
    static let seafoamGreen = Color(hex: "71EEB8")
    
    // Gradient greens
    static let gradientStart = Color(hex: "6FCF97")
    static let gradientEnd = Color(hex: "27AE60")
    static let lightGradientStart = Color(hex: "A8E6CF")
    static let lightGradientEnd = Color(hex: "56AB91")
    
    // Route colors
    static let routeGreen = Color(hex: "52C41A")
    static let routeGlow = Color(hex: "95DE64")
    
    // Calendar intensity
    static let calendarLight = Color(hex: "B7EB8F")
    static let calendarMedium = Color(hex: "73D13D")
    static let calendarDark = Color(hex: "389E0D")
    
    // UI colors
    static let cardBackground = Color(hex: "F8FDF9")
    static let softBackground = Color(hex: "F0FFF4")
    static let warmWhite = Color(hex: "FAFFFE")
    static let shadowGreen = Color(hex: "2F855A").opacity(0.15)
    
    // Accent colors
    static let coral = Color(hex: "FF6B6B")
    static let sunset = Color(hex: "FFA502")
    static let ocean = Color(hex: "54A0FF")
    static let lavender = Color(hex: "A29BFE")
    
    // Text colors
    static let textPrimary = Color(hex: "1A1A2E")
    static let textSecondary = Color(hex: "6B7280")
    static let textMuted = Color(hex: "9CA3AF")
    
    // Destructive
    static let destructiveRed = Color(hex: "FF3B30")
    static let finishRed = Color(hex: "EF4444")
    
    // Gradients
    static var startWalkGradient: LinearGradient {
        LinearGradient(
            colors: [gradientStart, gradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var heroGradient: LinearGradient {
        LinearGradient(
            colors: [lightGradientStart, primaryGreen, gradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var softGreenGradient: LinearGradient {
        LinearGradient(
            colors: [softBackground, warmWhite],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    static var cardGradient: LinearGradient {
        LinearGradient(
            colors: [cardBackground, Color.white],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var meshGradient: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "E8F5E9"),
                    Color(hex: "F1F8E9"),
                    Color(hex: "F9FBE7")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            Circle()
                .fill(primaryGreen.opacity(0.1))
                .blur(radius: 60)
                .offset(x: -100, y: -50)
            
            Circle()
                .fill(emeraldGreen.opacity(0.08))
                .blur(radius: 80)
                .offset(x: 100, y: 100)
        }
    }
}

// Color extension to support hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


