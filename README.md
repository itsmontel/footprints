# 🚶 Footprints - Walk Tracking iOS App

A beautiful iOS app for tracking your walks with GPS, photos, and journal entries. Capture your walking memories and view them on interactive maps.

![iOS 16.0+](https://img.shields.io/badge/iOS-16.0+-green.svg)
![Swift 5.9](https://img.shields.io/badge/Swift-5.9-orange.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-4.0-blue.svg)

## ✨ Features

### 🏠 Home Tab
- **Weekly Statistics Card** - Track your distance, walk count, and total time
- **Start Walk Button** - Beautiful green gradient button to begin tracking
- **Calendar Widget** - Compact monthly view with walk intensity indicators
- **Recent Walks** - Quick access to your last 5 walks

### 📍 Active Tracking
- **Real-time GPS Tracking** - Watch your route draw on the map
- **Live Stats** - Distance, time, and pace updating in real-time
- **Beautiful Map** - Apple MapKit with green route lines
- **Start/End Markers** - Visual indicators for your journey

### 📜 History Tab
- **List View** - Scrollable list of all walks with thumbnails
- **Calendar View** - Month grid with walk intensity colors
- **Easy Navigation** - Tap any walk to see full details
- **Swipe to Delete** - Quick data management

### 🗺️ Photo Map
- **Photo Pins** - See all your photos on a map at their GPS locations
- **Time Filters** - Filter by All Time, This Year, This Month, This Week
- **Photo Popup** - Tap pins to preview photos and view walks
- **Grid Panel** - Slide-up panel showing all photos

### 📸 Walk Details
- **Route Map** - Full view of your completed walk
- **Statistics** - Distance, duration, and average pace
- **Photo Grid** - Add and view photos from your walk
- **Journal Notes** - Write memories about your journey

### ⚙️ Settings
- **Distance Units** - Toggle between kilometers and miles
- **Data Management** - Clear all data option
- **About Section** - App version and information

## 🎨 Design Highlights

- **Green Color Scheme** - Fresh, nature-inspired palette
- **Smooth Animations** - Spring animations throughout
- **Card-based UI** - Modern, floating card design
- **Gradient Accents** - Beautiful color transitions
- **SF Symbols** - Consistent iOS iconography

## 🏗️ Architecture

```
Footprints/
├── App/
│   ├── FootprintsApp.swift      # App entry point
│   └── ContentView.swift        # Main tab navigation
├── Models/
│   ├── Walk+Extensions.swift    # CoreData model extensions
│   ├── PhotoLocation.swift      # Photo GPS data struct
│   └── LocationManager.swift    # GPS tracking manager
├── ViewModels/
│   ├── WalkingViewModel.swift   # Main walk logic
│   ├── WalkDetailViewModel.swift
│   ├── PhotoMapViewModel.swift
│   └── CalendarViewModel.swift
├── Views/
│   ├── Home/                    # Home tab views
│   ├── Tracking/                # Active tracking view
│   ├── Detail/                  # Walk detail views
│   ├── History/                 # History tab views
│   ├── PhotoMap/                # Photo map views
│   └── Settings/                # Settings view
├── Utilities/
│   ├── ColorScheme.swift        # App color constants
│   └── PhotoLocationExtractor.swift
└── Persistence/
    ├── PersistenceController.swift
    └── Footprints.xcdatamodeld
```

## 🔐 Permissions

The app requires the following permissions:
- **Location (When In Use)** - For GPS tracking during walks
- **Photo Library** - For adding photos to walks
- **Background Location** - For tracking while app is backgrounded

## 📱 Requirements

- iOS 16.0 or later
- iPhone or iPad
- Location services enabled
- Photo library access (optional)

## 🚀 Getting Started

1. Open `Footprints.xcodeproj` in Xcode
2. Select your development team in project settings
3. Build and run on a simulator or device
4. Grant location permissions when prompted
5. Start your first walk!

## 🛠️ Technologies

- **SwiftUI** - Modern declarative UI framework
- **CoreData** - Local data persistence
- **MapKit** - Map display and annotations
- **CoreLocation** - GPS tracking
- **PhotosUI** - Photo picker and metadata

## 📝 Data Storage

All data is stored locally on the device:
- Walk routes (coordinates)
- Statistics (distance, duration, pace)
- Photos (saved to Documents folder)
- Journal entries

No cloud sync, no account required, complete privacy.

## 🎯 Future Enhancements

- [ ] Apple Watch companion app
- [ ] Export walks to GPX files
- [ ] Share walks with friends
- [ ] Walking goals and achievements
- [ ] Health app integration
- [ ] Dark mode support

---

Made with ❤️ using SwiftUI


