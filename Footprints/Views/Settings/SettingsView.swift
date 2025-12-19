//
//  SettingsView.swift
//  Footprints
//
//  Settings screen with units, data management, and about section
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var walkingViewModel: WalkingViewModel
    @AppStorage("useMiles") private var useMiles = false
    
    @State private var showClearDataAlert = false
    @State private var showDataCleared = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.meshGradient
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Units Section
                        unitsSection
                        
                        // Data Section
                        dataSection
                        
                        // About Section
                        aboutSection
                        
                        // App branding
                        appBranding
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert("Clear All Data?", isPresented: $showClearDataAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All Data", role: .destructive) {
                    walkingViewModel.clearAllData()
                    showDataCleared = true
                }
            } message: {
                Text("This will permanently delete all your walks, photos, and journal entries. This cannot be undone.")
            }
            .alert("Data Cleared", isPresented: $showDataCleared) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("All walks and photos have been deleted.")
            }
        }
    }
    
    // MARK: - Units Section
    
    private var unitsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Units", icon: "ruler")
            
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Distance Unit")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("Changes how distances are displayed")
                            .font(.caption)
                            .foregroundColor(AppColors.textMuted)
                    }
                    
                    Spacer()
                    
                    Picker("", selection: $useMiles) {
                        Text("km").tag(false)
                        Text("mi").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 120)
                }
                .padding(16)
            }
            .background(settingsCardBackground)
        }
    }
    
    // MARK: - Data Section
    
    private var dataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "Data", icon: "externaldrive")
            
            VStack(spacing: 0) {
                // Storage info
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Local Storage")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("All data is stored locally on your device")
                            .font(.caption)
                            .foregroundColor(AppColors.textMuted)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "iphone")
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.primaryGreen)
                }
                .padding(16)
                
                Divider()
                    .padding(.horizontal, 16)
                
                // Clear data button
                Button(action: { showClearDataAlert = true }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Clear All Data")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppColors.destructiveRed)
                            
                            Text("Remove all walks, photos, and notes")
                                .font(.caption)
                                .foregroundColor(AppColors.textMuted)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "trash")
                            .font(.system(size: 18))
                            .foregroundColor(AppColors.destructiveRed)
                    }
                    .padding(16)
                }
            }
            .background(settingsCardBackground)
        }
    }
    
    // MARK: - About Section
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "About", icon: "info.circle")
            
            VStack(spacing: 0) {
                infoRow(title: "App Version", value: "1.0.0")
                
                Divider()
                    .padding(.horizontal, 16)
                
                infoRow(title: "Build", value: "1")
                
                Divider()
                    .padding(.horizontal, 16)
                
                infoRow(title: "iOS Target", value: "16.0+")
            }
            .background(settingsCardBackground)
        }
    }
    
    // MARK: - App Branding
    
    private var appBranding: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppColors.gradientStart, AppColors.gradientEnd],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 70)
                    .shadow(color: AppColors.primaryGreen.opacity(0.3), radius: 10, y: 5)
                
                Image(systemName: "figure.walk")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 4) {
                Text("Footprints")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppColors.primaryGreen, AppColors.forestGreen],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("Track your journey, one step at a time")
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.textMuted)
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Helper Views
    
    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColors.primaryGreen)
            
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppColors.textSecondary)
                .textCase(.uppercase)
        }
        .padding(.leading, 4)
    }
    
    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(16)
    }
    
    private var settingsCardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.white)
            .shadow(color: AppColors.shadowGreen, radius: 10, y: 5)
    }
}

#Preview {
    SettingsView()
        .environmentObject(WalkingViewModel())
}


