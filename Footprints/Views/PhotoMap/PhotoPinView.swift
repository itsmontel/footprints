//
//  PhotoPinView.swift
//  Footprints
//
//  Custom photo pin annotation view for the map
//

import SwiftUI

struct PhotoPinView: View {
    let photoURL: String
    let isSelected: Bool
    
    @State private var image: UIImage?
    
    var body: some View {
        ZStack {
            // Pin shadow
            Circle()
                .fill(.black.opacity(0.2))
                .frame(width: isSelected ? 56 : 44, height: isSelected ? 56 : 44)
                .blur(radius: 4)
                .offset(y: 4)
            
            // Pin background
            Circle()
                .fill(.white)
                .frame(width: isSelected ? 52 : 40, height: isSelected ? 52 : 40)
            
            // Photo thumbnail
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: isSelected ? 44 : 32, height: isSelected ? 44 : 32)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(AppColors.softBackground)
                    .frame(width: isSelected ? 44 : 32, height: isSelected ? 44 : 32)
                    .overlay(
                        Image(systemName: "camera.fill")
                            .font(.system(size: isSelected ? 18 : 12))
                            .foregroundColor(AppColors.primaryGreen.opacity(0.5))
                    )
            }
            
            // Selected border
            if isSelected {
                Circle()
                    .stroke(AppColors.primaryGreen, lineWidth: 4)
                    .frame(width: 52, height: 52)
            }
        }
        .onAppear {
            loadImage()
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
    
    private func loadImage() {
        guard let url = URL(string: photoURL) else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let data = try? Data(contentsOf: url),
               let loadedImage = UIImage(data: data) {
                // Create thumbnail
                let thumbnail = loadedImage.preparingThumbnail(of: CGSize(width: 100, height: 100))
                DispatchQueue.main.async {
                    self.image = thumbnail ?? loadedImage
                }
            }
        }
    }
}

// MARK: - Photo Cluster View

struct PhotoClusterView: View {
    let count: Int
    
    var body: some View {
        ZStack {
            // Shadow
            Circle()
                .fill(.black.opacity(0.15))
                .frame(width: 54, height: 54)
                .blur(radius: 4)
                .offset(y: 3)
            
            // Background
            Circle()
                .fill(
                    LinearGradient(
                        colors: [AppColors.lightGradientStart, AppColors.primaryGreen],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 50, height: 50)
            
            // Inner content
            VStack(spacing: 1) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("\(count)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        HStack(spacing: 30) {
            PhotoPinView(photoURL: "", isSelected: false)
            PhotoPinView(photoURL: "", isSelected: true)
        }
        
        PhotoClusterView(count: 12)
    }
    .padding()
    .background(Color.gray.opacity(0.2))
}


