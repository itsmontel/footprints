//
//  FootprintsApp.swift
//  Footprints
//
//  A beautiful walk tracking app with GPS, photos, and memories
//

import SwiftUI

@main
struct FootprintsApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var walkingViewModel = WalkingViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(walkingViewModel)
                .preferredColorScheme(.light)
        }
    }
}


