//
//  WalkDetailView.swift
//  Footprints
//
//  Detailed view of a completed walk with map, stats, photos, and journal
//

import SwiftUI
import PhotosUI
import MapKit
import CoreData

struct WalkDetailView: View {
    @StateObject private var viewModel: WalkDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedPhotoIndex: Int?
    @State private var showPhotoViewer = false
    
    init(walk: Walk) {
        _viewModel = StateObject(wrappedValue: WalkDetailViewModel(walk: walk))
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Map
                mapSection
                
                // Stats
                statsSection
                
                // Photos
                photosSection
                
                // Journal
                journalSection
            }
            .padding(.bottom, 30)
        }
        .background(AppColors.softGreenGradient.ignoresSafeArea())
        .navigationTitle(viewModel.walk.shortDate)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        // Delete walk
                    } label: {
                        Label("Delete Walk", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(AppColors.primaryGreen)
                }
            }
        }
        .sheet(isPresented: $showPhotoViewer) {
            if let index = selectedPhotoIndex, index < viewModel.photos.count {
                PhotoViewerSheet(
                    photos: viewModel.photos,
                    selectedIndex: index
                )
            }
        }
        .onChange(of: selectedItems) { items in
            Task {
                let photoItems = await processSelectedPhotos(items)
                await viewModel.addPhotos(from: photoItems)
                selectedItems = []
            }
        }
    }
    
    // MARK: - Map Section
    
    private var mapSection: some View {
        ZStack {
            MapRouteView(walk: viewModel.walk)
                .frame(height: 280)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(.white.opacity(0.5), lineWidth: 2)
                )
                .shadow(color: AppColors.shadowGreen, radius: 15, y: 8)
            
            // Day of week overlay
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.walk.dayOfWeek)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text(viewModel.walk.formattedDate)
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                    )
                    
                    Spacer()
                }
                .padding(16)
                
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
    
    // MARK: - Stats Section
    
    private var statsSection: some View {
        HStack(spacing: 12) {
            DetailStatCard(
                icon: "arrow.triangle.swap",
                value: viewModel.walk.formattedDistance,
                label: "Distance",
                color: AppColors.primaryGreen
            )
            
            DetailStatCard(
                icon: "clock",
                value: viewModel.walk.formattedDurationLong,
                label: "Duration",
                color: AppColors.ocean
            )
            
            DetailStatCard(
                icon: "speedometer",
                value: viewModel.walk.formattedPace,
                label: "Pace",
                color: AppColors.lavender
            )
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Photos Section
    
    private var photosSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.primaryGreen)
                    
                    Text("Photos")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    if viewModel.walk.photoCount > 0 {
                        Text("\(viewModel.walk.photoCount)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(AppColors.primaryGreen))
                    }
                }
                
                Spacer()
                
                PhotosPicker(selection: $selectedItems, matching: .images) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                        Text("Add")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(AppColors.primaryGreen)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(AppColors.primaryGreen.opacity(0.12))
                    )
                }
            }
            
            if viewModel.photos.isEmpty {
                emptyPhotosView
            } else {
                PhotoGridView(
                    photos: viewModel.photos,
                    onPhotoTap: { index in
                        selectedPhotoIndex = index
                        showPhotoViewer = true
                    },
                    onPhotoDelete: { index in
                        viewModel.deletePhoto(at: index)
                    }
                )
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: AppColors.shadowGreen, radius: 10, y: 5)
        )
        .padding(.horizontal, 16)
    }
    
    private var emptyPhotosView: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppColors.primaryGreen.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "camera")
                    .font(.system(size: 24))
                    .foregroundColor(AppColors.primaryGreen.opacity(0.5))
            }
            
            Text("No photos yet")
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
            
            Text("Add photos from your walk")
                .font(.caption)
                .foregroundColor(AppColors.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }
    
    // MARK: - Journal Section
    
    private var journalSection: some View {
        JournalNoteView(viewModel: viewModel)
            .padding(.horizontal, 16)
    }
    
    // MARK: - Photo Processing
    
    private func processSelectedPhotos(_ items: [PhotosPickerItem]) async -> [PhotoPickerItem] {
        var result: [PhotoPickerItem] = []
        
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self) {
                // Get the PHAsset for GPS data
                let asset = await fetchAsset(for: item)
                result.append(PhotoPickerItem(data: data, asset: asset))
            }
        }
        
        return result
    }
    
    private func fetchAsset(for item: PhotosPickerItem) async -> PHAsset? {
        guard let identifier = item.itemIdentifier else { return nil }
        
        let results = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
        return results.firstObject
    }
}

// MARK: - Detail Stat Card

struct DetailStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text(label)
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: AppColors.shadowGreen, radius: 8, y: 4)
        )
    }
}

#Preview {
    NavigationStack {
        WalkDetailView(walk: Walk(context: PersistenceController.preview.container.viewContext))
    }
}

