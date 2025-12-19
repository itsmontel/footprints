//
//  ContentView.swift
//  Footprints
//
//  Main tab navigation with 4 tabs: Home, History, Photo Map, Settings
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var walkingViewModel: WalkingViewModel
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)
                
                WalkHistoryView()
                    .tabItem {
                        Label("History", systemImage: "clock.fill")
                    }
                    .tag(1)
                
                PhotoMapView()
                    .tabItem {
                        Label("Photo Map", systemImage: "map.fill")
                    }
                    .tag(2)
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(3)
            }
            .tint(AppColors.primaryGreen)
            
            // Full screen active tracking overlay
            if walkingViewModel.isTracking {
                ActiveTrackingView()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: walkingViewModel.isTracking)
    }
}

#Preview {
    ContentView()
        .environmentObject(WalkingViewModel())
}


