//
//  PhotoGridView.swift
//  Footprints
//
//  Grid view for displaying walk photos with tap and delete actions
//

import SwiftUI

struct PhotoGridView: View {
    let photos: [UIImage]
    let onPhotoTap: (Int) -> Void
    let onPhotoDelete: (Int) -> Void
    
    @State private var showDeleteConfirmation = false
    @State private var photoToDelete: Int?
    
    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(Array(photos.enumerated()), id: \.offset) { index, image in
                PhotoThumbnail(image: image)
                    .onTapGesture {
                        onPhotoTap(index)
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            photoToDelete = index
                            showDeleteConfirmation = true
                        } label: {
                            Label("Delete Photo", systemImage: "trash")
                        }
                    }
            }
        }
        .alert("Delete Photo?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {
                photoToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let index = photoToDelete {
                    onPhotoDelete(index)
                }
                photoToDelete = nil
            }
        } message: {
            Text("This photo will be permanently removed.")
        }
    }
}

// MARK: - Photo Thumbnail

struct PhotoThumbnail: View {
    let image: UIImage
    
    var body: some View {
        GeometryReader { geometry in
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: geometry.size.width, height: geometry.size.width)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Photo Viewer Sheet

struct PhotoViewerSheet: View {
    let photos: [UIImage]
    let selectedIndex: Int
    
    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex: Int
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    
    init(photos: [UIImage], selectedIndex: Int) {
        self.photos = photos
        self.selectedIndex = selectedIndex
        _currentIndex = State(initialValue: selectedIndex)
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            TabView(selection: $currentIndex) {
                ForEach(Array(photos.enumerated()), id: \.offset) { index, image in
                    ZoomableImageView(image: image)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            
            // Close button
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Circle().fill(.white.opacity(0.2)))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                Spacer()
                
                // Photo counter
                Text("\(currentIndex + 1) of \(photos.count)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.bottom, 50)
            }
        }
    }
}

// MARK: - Zoomable Image View

struct ZoomableImageView: View {
    let image: UIImage
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .scaleEffect(scale)
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        scale = lastScale * value
                    }
                    .onEnded { _ in
                        lastScale = scale
                        if scale < 1.0 {
                            withAnimation(.spring()) {
                                scale = 1.0
                                lastScale = 1.0
                            }
                        }
                    }
            )
            .onTapGesture(count: 2) {
                withAnimation(.spring()) {
                    if scale > 1.0 {
                        scale = 1.0
                        lastScale = 1.0
                    } else {
                        scale = 2.0
                        lastScale = 2.0
                    }
                }
            }
    }
}

#Preview {
    PhotoGridView(
        photos: [UIImage(systemName: "photo")!, UIImage(systemName: "photo")!],
        onPhotoTap: { _ in },
        onPhotoDelete: { _ in }
    )
    .padding()
}


