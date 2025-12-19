//
//  MapRouteView.swift
//  Footprints
//
//  Static map view showing the walk route with start/end pins
//

import SwiftUI
import MapKit
import CoreLocation
import CoreData

struct MapRouteView: View {
    let walk: Walk
    
    @State private var region: MKCoordinateRegion
    
    init(walk: Walk) {
        self.walk = walk
        _region = State(initialValue: walk.mapRegion)
    }
    
    var body: some View {
        Map(coordinateRegion: .constant(region), interactionModes: [], annotationItems: annotations) { annotation in
            MapAnnotation(coordinate: annotation.coordinate) {
                annotation.view
            }
        }
        .allowsHitTesting(false)
    }
    
    private var annotations: [MapAnnotationItem] {
        var items: [MapAnnotationItem] = []
        
        // Start marker
        if let start = walk.startCoordinate {
            items.append(MapAnnotationItem(
                coordinate: start,
                view: AnyView(startMarker)
            ))
        }
        
        // End marker
        if let end = walk.endCoordinate, walk.coordinates.count > 1 {
            items.append(MapAnnotationItem(
                coordinate: end,
                view: AnyView(endMarker)
            ))
        }
        
        return items
    }
    
    private var startMarker: some View {
        ZStack {
            Circle()
                .fill(.white)
                .frame(width: 32, height: 32)
                .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
            
            Circle()
                .fill(AppColors.primaryGreen)
                .frame(width: 24, height: 24)
            
            Image(systemName: "flag.fill")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
        }
    }
    
    private var endMarker: some View {
        ZStack {
            Circle()
                .fill(.white)
                .frame(width: 32, height: 32)
                .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
            
            Circle()
                .fill(AppColors.coral)
                .frame(width: 24, height: 24)
            
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Interactive Map Route View

struct InteractiveMapRouteView: View {
    let walk: Walk
    @Binding var region: MKCoordinateRegion
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, annotationItems: annotations) { annotation in
                MapAnnotation(coordinate: annotation.coordinate) {
                    annotation.view
                }
            }
            
            // Route polyline overlay would go here if needed
            // For iOS 16, we'll just show the route through MapPolyline in a different way
        }
    }
    
    private var annotations: [MapAnnotationItem] {
        var items: [MapAnnotationItem] = []
        
        // Start marker
        if let start = walk.startCoordinate {
            items.append(MapAnnotationItem(
                coordinate: start,
                view: AnyView(
                    ZStack {
                        Circle()
                            .fill(.white)
                            .frame(width: 28, height: 28)
                            .shadow(radius: 3)
                        
                        Circle()
                            .fill(AppColors.primaryGreen)
                            .frame(width: 20, height: 20)
                    }
                )
            ))
        }
        
        // End marker
        if let end = walk.endCoordinate, walk.coordinates.count > 1 {
            items.append(MapAnnotationItem(
                coordinate: end,
                view: AnyView(
                    ZStack {
                        Circle()
                            .fill(.white)
                            .frame(width: 28, height: 28)
                            .shadow(radius: 3)
                        
                        Circle()
                            .fill(AppColors.coral)
                            .frame(width: 20, height: 20)
                    }
                )
            ))
        }
        
        // Photo locations
        for location in walk.photoLocations {
            items.append(MapAnnotationItem(
                coordinate: location.coordinate,
                view: AnyView(
                    ZStack {
                        Circle()
                            .fill(.white)
                            .frame(width: 24, height: 24)
                            .shadow(radius: 2)
                        
                        Image(systemName: "camera.fill")
                            .font(.system(size: 10))
                            .foregroundColor(AppColors.ocean)
                    }
                )
            ))
        }
        
        return items
    }
}

#Preview {
    MapRouteView(walk: Walk(context: PersistenceController.preview.container.viewContext))
        .frame(height: 300)
        .padding()
}
