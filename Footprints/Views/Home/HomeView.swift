//
//  HomeView.swift
//  Footprints
//
//  Beautiful home screen with stats, calendar widget, and recent walks
//

import SwiftUI
import CoreData
import CoreLocation

struct HomeView: View {
    @EnvironmentObject var walkingViewModel: WalkingViewModel
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Walk.date, ascending: false)],
        animation: .default)
    private var walks: FetchedResults<Walk>
    
    @State private var weeklyStats: (distance: Double, count: Int, duration: Double) = (0, 0, 0)
    @State private var showWalkDetail = false
    @State private var selectedWalk: Walk?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Beautiful gradient background
                AppColors.meshGradient
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header
                        headerView
                        
                        // Weekly Stats Card
                        WeeklyStatsCard(stats: weeklyStats)
                            .padding(.horizontal)
                        
                        // Start Walk Button
                        startWalkButton
                            .padding(.horizontal)
                        
                        // Mini Calendar Widget
                        MiniCalendarWidget()
                            .padding(.horizontal)
                        
                        // Recent Walks Section
                        recentWalksSection
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                weeklyStats = walkingViewModel.fetchWeeklyStats()
            }
            .onChange(of: walks.count) { _ in
                weeklyStats = walkingViewModel.fetchWeeklyStats()
            }
            .navigationDestination(isPresented: $showWalkDetail) {
                if let walk = selectedWalk {
                    WalkDetailView(walk: walk)
                }
            }
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                
                Text("Footprints")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppColors.primaryGreen, AppColors.forestGreen],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            
            Spacer()
            
            // Decorative icon
            ZStack {
                Circle()
                    .fill(AppColors.primaryGreen.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "figure.walk")
                    .font(.system(size: 24))
                    .foregroundColor(AppColors.primaryGreen)
            }
        }
        .padding(.horizontal)
    }
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<21: return "Good evening"
        default: return "Good night"
        }
    }
    
    // MARK: - Start Walk Button
    
    private var startWalkButton: some View {
        Button(action: {
            walkingViewModel.startWalk()
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: "figure.walk")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Start Walk")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Begin tracking your journey")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(20)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(AppColors.startWalkGradient)
                    
                    // Decorative circles
                    Circle()
                        .fill(.white.opacity(0.1))
                        .frame(width: 100, height: 100)
                        .offset(x: 120, y: -30)
                    
                    Circle()
                        .fill(.white.opacity(0.08))
                        .frame(width: 60, height: 60)
                        .offset(x: -100, y: 40)
                }
                .clipShape(RoundedRectangle(cornerRadius: 24))
            )
            .shadow(color: AppColors.primaryGreen.opacity(0.4), radius: 20, x: 0, y: 10)
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Recent Walks Section
    
    private var recentWalksSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Walks")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                if !walks.isEmpty {
                    NavigationLink(destination: WalkHistoryView()) {
                        Text("See All")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(AppColors.primaryGreen)
                    }
                }
            }
            .padding(.horizontal)
            
            if walks.isEmpty {
                emptyRecentWalksView
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(walks.prefix(5)), id: \.id) { walk in
                        RecentWalkCard(walk: walk)
                            .onTapGesture {
                                selectedWalk = walk
                                showWalkDetail = true
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var emptyRecentWalksView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppColors.primaryGreen.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "figure.walk.motion")
                    .font(.system(size: 36))
                    .foregroundColor(AppColors.primaryGreen.opacity(0.6))
            }
            
            Text("No walks yet")
                .font(.headline)
                .foregroundColor(AppColors.textSecondary)
            
            Text("Start your first walk to see it here!")
                .font(.subheadline)
                .foregroundColor(AppColors.textMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white.opacity(0.7))
        )
        .padding(.horizontal)
    }
}

// MARK: - Recent Walk Card

struct RecentWalkCard: View {
    let walk: Walk
    
    var body: some View {
        HStack(spacing: 14) {
            // Mini map placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [AppColors.softBackground, AppColors.mintGreen.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 70)
                
                if !walk.coordinates.isEmpty {
                    MiniRoutePreview(coordinates: walk.coordinates)
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Image(systemName: "map")
                        .font(.system(size: 24))
                        .foregroundColor(AppColors.primaryGreen.opacity(0.5))
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(walk.shortDate)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                HStack(spacing: 12) {
                    Label(walk.formattedDistance, systemImage: "arrow.triangle.swap")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Label(walk.formattedDurationLong, systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            Spacer()
            
            // Indicators
            HStack(spacing: 6) {
                if walk.hasPhotos {
                    Image(systemName: "camera.fill")
                        .font(.caption)
                        .foregroundColor(AppColors.ocean)
                }
                
                if walk.hasJournal {
                    Image(systemName: "note.text")
                        .font(.caption)
                        .foregroundColor(AppColors.lavender)
                }
            }
            
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundColor(AppColors.textMuted)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: AppColors.shadowGreen, radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Mini Route Preview

struct MiniRoutePreview: View {
    let coordinates: [CLLocationCoordinate2D]
    
    var body: some View {
        GeometryReader { geometry in
            if coordinates.count >= 2 {
                Path { path in
                    let points = normalizedPoints(in: geometry.size)
                    guard let first = points.first else { return }
                    path.move(to: first)
                    for point in points.dropFirst() {
                        path.addLine(to: point)
                    }
                }
                .stroke(
                    AppColors.routeGreen,
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
                )
            }
        }
    }
    
    private func normalizedPoints(in size: CGSize) -> [CGPoint] {
        guard !coordinates.isEmpty else { return [] }
        
        let lats = coordinates.map { $0.latitude }
        let lons = coordinates.map { $0.longitude }
        
        guard let minLat = lats.min(),
              let maxLat = lats.max(),
              let minLon = lons.min(),
              let maxLon = lons.max() else { return [] }
        
        let latRange = max(maxLat - minLat, 0.0001)
        let lonRange = max(maxLon - minLon, 0.0001)
        
        let padding: CGFloat = 4
        let drawWidth = size.width - padding * 2
        let drawHeight = size.height - padding * 2
        
        return coordinates.map { coord in
            let x = CGFloat((coord.longitude - minLon) / lonRange) * drawWidth + padding
            let y = CGFloat(1 - (coord.latitude - minLat) / latRange) * drawHeight + padding
            return CGPoint(x: x, y: y)
        }
    }
}

// MARK: - Scale Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    HomeView()
        .environmentObject(WalkingViewModel())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

