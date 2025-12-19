//
//  PhotoMapFilterBar.swift
//  Footprints
//
//  Filter bar for the Photo Map with time period selection
//

import SwiftUI

struct PhotoMapFilterBar: View {
    @Binding var selectedFilter: PhotoMapViewModel.TimeFilter
    let photoCount: Int
    let walkCount: Int
    
    var body: some View {
        VStack(spacing: 10) {
            // Filter buttons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(PhotoMapViewModel.TimeFilter.allCases, id: \.self) { filter in
                        FilterButton(
                            title: filter.rawValue,
                            isSelected: selectedFilter == filter
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedFilter = filter
                            }
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.08), radius: 10, y: 5)
        )
    }
}

// MARK: - Filter Button

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isSelected ? .white : AppColors.primaryGreen)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? AppColors.primaryGreen : AppColors.primaryGreen.opacity(0.12))
                )
        }
    }
}

// MARK: - Photo Popup View

struct PhotoPopupView: View {
    let annotation: PhotoAnnotationData
    let onClose: () -> Void
    let onViewWalk: () -> Void
    
    @State private var image: UIImage?
    
    var body: some View {
        VStack(spacing: 0) {
            // Close button
            HStack {
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppColors.textSecondary)
                        .padding(8)
                        .background(Circle().fill(AppColors.softBackground))
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            
            HStack(spacing: 14) {
                // Photo preview
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColors.softBackground)
                        .frame(width: 100, height: 100)
                    
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        Image(systemName: "photo")
                            .font(.system(size: 30))
                            .foregroundColor(AppColors.textMuted)
                    }
                }
                
                // Info
                VStack(alignment: .leading, spacing: 8) {
                    Text(annotation.formattedDate)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("From walk on \(annotation.shortDate)")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                    
                    Spacer()
                    
                    Button(action: onViewWalk) {
                        HStack(spacing: 4) {
                            Text("View Walk")
                                .font(.system(size: 13, weight: .semibold))
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(AppColors.primaryGreen)
                        )
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .frame(height: 160)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
        )
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        guard let url = URL(string: annotation.photoURL) else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let data = try? Data(contentsOf: url),
               let loadedImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = loadedImage
                }
            }
        }
    }
}

// MARK: - Photo Grid Panel

struct PhotoGridPanel: View {
    let annotations: [PhotoAnnotationData]
    let onPhotoTap: (PhotoAnnotationData) -> Void
    
    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Photos")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Text("\(annotations.count) photos")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(annotations) { annotation in
                        PhotoGridItem(photoURL: annotation.photoURL)
                            .onTapGesture {
                                onPhotoTap(annotation)
                            }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
        }
        .background(Color.white)
    }
}

// MARK: - Photo Grid Item

struct PhotoGridItem: View {
    let photoURL: String
    @State private var image: UIImage?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(AppColors.softBackground)
                
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.width)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    ProgressView()
                        .tint(AppColors.primaryGreen)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        guard let url = URL(string: photoURL) else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let data = try? Data(contentsOf: url),
               let loadedImage = UIImage(data: data) {
                let thumbnail = loadedImage.preparingThumbnail(of: CGSize(width: 200, height: 200))
                DispatchQueue.main.async {
                    self.image = thumbnail ?? loadedImage
                }
            }
        }
    }
}

#Preview {
    PhotoMapFilterBar(
        selectedFilter: .constant(.allTime),
        photoCount: 47,
        walkCount: 12
    )
    .padding()
}


