//
//  PhotoMapView.swift
//  Footprints
//
//  Full-screen map showing all photos at their GPS locations
//

import SwiftUI
import MapKit
import CoreLocation
import CoreData

struct PhotoMapView: View {
    @StateObject private var viewModel = PhotoMapViewModel()
    @State private var showPhotoPopup = false
    @State private var selectedAnnotation: PhotoAnnotationData?
    @State private var showWalkDetail = false
    @State private var selectedWalk: Walk?
    @State private var showPhotoGrid = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Map (iOS 16 compatible)
                Map(coordinateRegion: $viewModel.mapRegion, annotationItems: viewModel.photoAnnotations) { annotation in
                    MapAnnotation(coordinate: annotation.coordinate) {
                        PhotoPinView(
                            photoURL: annotation.photoURL,
                            isSelected: selectedAnnotation?.id == annotation.id
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedAnnotation = annotation
                                showPhotoPopup = true
                            }
                        }
                    }
                }
                .ignoresSafeArea(edges: .bottom)
                
                // Overlays
                VStack(spacing: 0) {
                    // Filter bar
                    PhotoMapFilterBar(
                        selectedFilter: $viewModel.selectedFilter,
                        photoCount: viewModel.totalPhotos,
                        walkCount: viewModel.totalWalks
                    )
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    Spacer()
                    
                    // Photo popup
                    if showPhotoPopup, let annotation = selectedAnnotation {
                        PhotoPopupView(
                            annotation: annotation,
                            onClose: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    showPhotoPopup = false
                                    selectedAnnotation = nil
                                }
                            },
                            onViewWalk: {
                                if let walk = viewModel.fetchWalk(for: annotation.walkId) {
                                    selectedWalk = walk
                                    showWalkDetail = true
                                }
                            }
                        )
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    
                    // Bottom info panel toggle
                    if !viewModel.photoAnnotations.isEmpty && !showPhotoPopup {
                        bottomInfoButton
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                    }
                }
                
                // Empty state
                if viewModel.photoAnnotations.isEmpty {
                    emptyStateOverlay
                }
            }
            .navigationTitle("Photo Map")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.loadPhotoAnnotations()
            }
            .sheet(isPresented: $showPhotoGrid) {
                PhotoGridPanel(
                    annotations: viewModel.photoAnnotations,
                    onPhotoTap: { annotation in
                        viewModel.centerOnPhoto(annotation)
                        selectedAnnotation = annotation
                        showPhotoPopup = true
                        showPhotoGrid = false
                    }
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
            .navigationDestination(isPresented: $showWalkDetail) {
                if let walk = selectedWalk {
                    WalkDetailView(walk: walk)
                }
            }
        }
    }
    
    // MARK: - Bottom Info Button
    
    private var bottomInfoButton: some View {
        Button(action: { showPhotoGrid = true }) {
            HStack(spacing: 10) {
                Image(systemName: "photo.stack")
                    .font(.system(size: 16, weight: .semibold))
                
                Text("\(viewModel.totalPhotos) photos across \(viewModel.totalWalks) walks")
                    .font(.system(size: 14, weight: .medium))
                
                Spacer()
                
                Image(systemName: "chevron.up")
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(AppColors.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
            )
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateOverlay: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(AppColors.primaryGreen.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "map")
                    .font(.system(size: 40))
                    .foregroundColor(AppColors.primaryGreen.opacity(0.5))
                
                Image(systemName: "camera.fill")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.primaryGreen)
                    .offset(x: 25, y: 25)
            }
            
            VStack(spacing: 8) {
                Text("No photos yet")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Add photos to your walks to see them\non the map at their exact locations")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
        )
        .padding(.horizontal, 40)
    }
}

#Preview {
    PhotoMapView()
}

