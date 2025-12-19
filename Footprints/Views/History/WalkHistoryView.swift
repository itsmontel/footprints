//
//  WalkHistoryView.swift
//  Footprints
//
//  History tab with list and calendar view options
//

import SwiftUI
import CoreData

struct WalkHistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var walkingViewModel: WalkingViewModel
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Walk.date, ascending: false)],
        animation: .default)
    private var walks: FetchedResults<Walk>
    
    @State private var viewMode: ViewMode = .list
    @State private var selectedWalk: Walk?
    @State private var showWalkDetail = false
    @State private var showDeleteConfirmation = false
    @State private var walkToDelete: Walk?
    
    enum ViewMode: String, CaseIterable {
        case list = "List"
        case calendar = "Calendar"
        
        var icon: String {
            switch self {
            case .list: return "list.bullet"
            case .calendar: return "calendar"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.meshGradient
                    .ignoresSafeArea()
                
                if walks.isEmpty {
                    emptyStateView
                } else {
                    VStack(spacing: 0) {
                        // View mode toggle
                        viewModeToggle
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        // Content based on view mode
                        if viewMode == .list {
                            listView
                        } else {
                            CalendarView(onWalkSelected: { walk in
                                selectedWalk = walk
                                showWalkDetail = true
                            })
                        }
                    }
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showWalkDetail) {
                if let walk = selectedWalk {
                    NavigationView {
                        WalkDetailView(walk: walk)
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button("Done") {
                                        showWalkDetail = false
                                    }
                                }
                            }
                    }
                }
            }
            .alert("Delete Walk?", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {
                    walkToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let walk = walkToDelete {
                        walkingViewModel.deleteWalk(walk)
                    }
                    walkToDelete = nil
                }
            } message: {
                Text("This walk and all its photos will be permanently deleted.")
            }
        }
    }
    
    // MARK: - View Mode Toggle
    
    private var viewModeToggle: some View {
        HStack(spacing: 0) {
            ForEach(ViewMode.allCases, id: \.self) { mode in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewMode = mode
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: mode.icon)
                            .font(.system(size: 14, weight: .semibold))
                        
                        Text(mode.rawValue)
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(viewMode == mode ? .white : AppColors.primaryGreen)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(viewMode == mode ? AppColors.primaryGreen : Color.clear)
                    )
                }
            }
        }
        .padding(4)
        .background(
            Capsule()
                .fill(.white)
                .shadow(color: AppColors.shadowGreen, radius: 8, y: 4)
        )
    }
    
    // MARK: - List View
    
    private var listView: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 12) {
                ForEach(walks, id: \.id) { walk in
                    WalkRowView(walk: walk)
                        .onTapGesture {
                            selectedWalk = walk
                            showWalkDetail = true
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                walkToDelete = walk
                                showDeleteConfirmation = true
                            } label: {
                                Label("Delete Walk", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                walkToDelete = walk
                                showDeleteConfirmation = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(AppColors.primaryGreen.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "figure.walk.motion")
                    .font(.system(size: 50))
                    .foregroundColor(AppColors.primaryGreen.opacity(0.6))
            }
            
            VStack(spacing: 8) {
                Text("No walks yet")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Start your first walk to see it here!")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    WalkHistoryView()
        .environmentObject(WalkingViewModel())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

