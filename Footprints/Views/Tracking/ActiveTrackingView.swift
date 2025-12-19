//
//  ActiveTrackingView.swift
//  Footprints
//
//  Full-screen active walk tracking with live map and stats
//

import SwiftUI
import MapKit
import CoreLocation

struct ActiveTrackingView: View {
    @EnvironmentObject var walkingViewModel: WalkingViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var showFinishedWalk = false
    @State private var finishedWalk: Walk?
    @State private var showCancelAlert = false
    
    var body: some View {
        ZStack {
            // Full-screen Map (iOS 16 compatible)
            Map(coordinateRegion: $region, interactionModes: [], showsUserLocation: true, userTrackingMode: .none, annotationItems: annotations) { annotation in
                MapAnnotation(coordinate: annotation.coordinate) {
                    annotation.view
                }
            } overlay: {
                // Route polyline
                if walkingViewModel.locationManager.trackedCoordinates.count >= 2 {
                    MapPolyline(coordinates: walkingViewModel.locationManager.trackedCoordinates)
                        .stroke(AppColors.routeGreen, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                }
            }
            .ignoresSafeArea()
            
            // Overlay UI
            VStack {
                // Top bar with cancel button
                HStack {
                    Button(action: { showCancelAlert = true }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                            .padding(12)
                            .background(
                                Circle()
                                    .fill(.white)
                                    .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                            )
                    }
                    
                    Spacer()
                    
                    // Recording indicator
                    HStack(spacing: 8) {
                        Circle()
                            .fill(AppColors.coral)
                            .frame(width: 10, height: 10)
                            .overlay(
                                Circle()
                                    .stroke(AppColors.coral.opacity(0.5), lineWidth: 2)
                                    .scaleEffect(1.5)
                            )
                        
                        Text("Recording")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(.white)
                            .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                    )
                    
                    Spacer()
                    
                    // Center on location button
                    Button(action: centerOnUser) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.ocean)
                            .padding(12)
                            .background(
                                Circle()
                                    .fill(.white)
                                    .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                Spacer()
                
                // Stats overlay at bottom
                statsOverlay
            }
        }
        .alert("Cancel Walk?", isPresented: $showCancelAlert) {
            Button("Continue Walking", role: .cancel) { }
            Button("Cancel Walk", role: .destructive) {
                walkingViewModel.cancelWalk()
            }
        } message: {
            Text("Your walk progress will be lost.")
        }
        .onChange(of: walkingViewModel.locationManager.currentLocation) { _ in
            updateCameraIfNeeded()
        }
        .onAppear {
            centerOnUser()
        }
        .navigationDestination(isPresented: $showFinishedWalk) {
            if let walk = finishedWalk {
                WalkDetailView(walk: walk)
            }
        }
    }
    
    // MARK: - Annotations
    
    private var annotations: [MapAnnotationItem] {
        var items: [MapAnnotationItem] = []
        
        // Start point
        if let start = walkingViewModel.locationManager.trackedCoordinates.first {
            items.append(MapAnnotationItem(
                coordinate: start,
                view: AnyView(
                    ZStack {
                        Circle()
                            .fill(.white)
                            .frame(width: 32, height: 32)
                            .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                        
                        Circle()
                            .fill(AppColors.primaryGreen)
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: "figure.walk")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                )
            ))
        }
        
        // Current position
        if let current = walkingViewModel.locationManager.currentLocation?.coordinate {
            items.append(MapAnnotationItem(
                coordinate: current,
                view: AnyView(
                    ZStack {
                        Circle()
                            .fill(AppColors.ocean.opacity(0.3))
                            .frame(width: 50, height: 50)
                        
                        Circle()
                            .fill(.white)
                            .frame(width: 24, height: 24)
                            .shadow(color: .black.opacity(0.2), radius: 3)
                        
                        Circle()
                            .fill(AppColors.ocean)
                            .frame(width: 16, height: 16)
                    }
                )
            ))
        }
        
        return items
    }
    
    // MARK: - Stats Overlay
    
    private var statsOverlay: some View {
        VStack(spacing: 0) {
            // Handle
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 10)
            
            VStack(spacing: 24) {
                // Main timer
                Text(walkingViewModel.formattedElapsedTime)
                    .font(.system(size: 56, weight: .bold, design: .monospaced))
                    .foregroundColor(AppColors.textPrimary)
                
                // Stats row
                HStack(spacing: 0) {
                    TrackingStatItem(
                        value: walkingViewModel.locationManager.formattedDistance,
                        label: "Distance",
                        icon: "arrow.triangle.swap"
                    )
                    
                    Divider()
                        .frame(height: 40)
                    
                    TrackingStatItem(
                        value: "\(walkingViewModel.currentPace)",
                        label: "Pace",
                        icon: "speedometer"
                    )
                    
                    Divider()
                        .frame(height: 40)
                    
                    TrackingStatItem(
                        value: "\(walkingViewModel.locationManager.trackedCoordinates.count)",
                        label: "Points",
                        icon: "mappin.circle"
                    )
                }
                
                // Finish button
                Button(action: finishWalk) {
                    HStack(spacing: 12) {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 20, weight: .bold))
                        
                        Text("Finish Walk")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [AppColors.finishRed, AppColors.coral],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .shadow(color: AppColors.finishRed.opacity(0.4), radius: 12, y: 6)
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 20, y: -10)
        )
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }
    
    // MARK: - Actions
    
    private func finishWalk() {
        finishedWalk = walkingViewModel.finishWalk()
        showFinishedWalk = true
    }
    
    private func centerOnUser() {
        if let location = walkingViewModel.locationManager.currentLocation {
            withAnimation(.easeInOut(duration: 0.5)) {
                region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                )
            }
        }
    }
    
    private func updateCameraIfNeeded() {
        // Auto-follow user while tracking
        if let location = walkingViewModel.locationManager.currentLocation {
            withAnimation(.easeInOut(duration: 0.3)) {
                region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            }
        }
    }
}

// MARK: - Map Annotation Item

struct MapAnnotationItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let view: AnyView
}

// MARK: - Tracking Stat Item

struct TrackingStatItem: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.primaryGreen)
                
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
            }
            
            Text(label)
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ActiveTrackingView()
        .environmentObject(WalkingViewModel())
}
