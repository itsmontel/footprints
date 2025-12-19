//
//  WalkRowView.swift
//  Footprints
//
//  Beautiful row view for displaying a walk in the history list
//

import SwiftUI
import CoreLocation
import CoreData

struct WalkRowView: View {
    let walk: Walk
    
    var body: some View {
        HStack(spacing: 14) {
            // Map thumbnail
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [AppColors.softBackground, AppColors.mintGreen.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                if !walk.coordinates.isEmpty {
                    MiniRoutePreview(coordinates: walk.coordinates)
                        .frame(width: 68, height: 68)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    Image(systemName: "map")
                        .font(.system(size: 28))
                        .foregroundColor(AppColors.primaryGreen.opacity(0.4))
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(walk.formattedDate)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                HStack(spacing: 14) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.triangle.swap")
                            .font(.system(size: 11))
                            .foregroundColor(AppColors.primaryGreen)
                        Text(walk.formattedDistance)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 11))
                            .foregroundColor(AppColors.ocean)
                        Text(walk.formattedDurationLong)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                if walk.hasJournal, let note = walk.journalNote {
                    Text(note)
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textMuted)
                        .italic()
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                buildIndicators()
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppColors.textMuted)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.white)
                .shadow(color: AppColors.shadowGreen, radius: 10, x: 0, y: 5)
        )
    }
    
    private func buildIndicators() -> some View {
        if walk.hasPhotos && walk.hasJournal {
            return AnyView(
                HStack(spacing: 6) {
                    photoBadge
                    journalIcon
                }
                .frame(height: 20)
            )
        } else if walk.hasPhotos {
            return AnyView(photoBadge.frame(height: 20))
        } else if walk.hasJournal {
            return AnyView(journalIcon.frame(height: 20))
        } else {
            return AnyView(Color.clear.frame(height: 20))
        }
    }
    
    private var photoBadge: some View {
        HStack(spacing: 2) {
            Image(systemName: "camera.fill")
                .font(.system(size: 10))
            Text("\(walk.photoCount)")
                .font(.system(size: 10, weight: .semibold))
        }
        .foregroundColor(AppColors.ocean)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(
            Capsule()
                .fill(AppColors.ocean.opacity(0.12))
        )
    }
    
    private var journalIcon: some View {
        Image(systemName: "note.text")
            .font(.system(size: 10))
            .foregroundColor(AppColors.lavender)
            .padding(5)
            .background(
                Circle()
                    .fill(AppColors.lavender.opacity(0.12))
            )
    }
}

#Preview {
    let walk = Walk(context: PersistenceController.preview.container.viewContext)
    walk.date = Date()
    walk.distance = 3450
    walk.duration = 1845
    walk.journalNote = "A lovely morning walk through the park"
    
    WalkRowView(walk: walk)
        .padding()
        .background(AppColors.meshGradient)
}
