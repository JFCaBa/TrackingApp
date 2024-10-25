# TrackingApp

A Swift app that automatically tracks and records your trips using motion detection and location services. The app intelligently detects when you start and stop traveling, saving all your journeys with detailed statistics.

## Features

- 🚗 Automatic trip detection using motion and location
- 📍 Background location tracking
- 📊 Detailed trip statistics (distance, speed, duration)
- 🗺️ Real-time map visualization
- 📱 Modern iOS design with Dark Mode support
- 🔋 Battery-efficient tracking algorithms
- 📈 Trip history with detailed insights

## Screenshots

![Simulator Screenshot](https://github.com/user-attachments/assets/5e70d9d2-489a-4d61-9892-baa9e8abb395)
![Simulator Screenshot](https://github.com/user-attachments/assets/2744d501-9d5f-4582-9183-70b505e33e36)
![Simulator Screenshot](https://github.com/user-attachments/assets/28ac68e0-55e0-4a6f-8b06-c07e5e4d0734)


## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.0+

## Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/TrackingApp.git
```

2. Open the project in Xcode
```bash
cd TrackingApp
open TrackingApp.xcodeproj
```

3. Build and run the project

## Architecture

The app follows the MVVM-C (Model-View-ViewModel-Coordinator) architecture pattern:

- **Models**: Core data entities for trips and locations
- **Views**: UIKit-based views with programmatic layout
- **ViewModels**: Business logic and data transformation
- **Coordinators**: Navigation flow management

### Key Components

- `AppCoordinator`: Main coordination and app flow
- `MapViewController`: Real-time trip visualization
- `TripsViewController`: Trip history and statistics
- `CoreDataManager`: Data persistence
- `MotionActivityManager`: Intelligent trip detection
- `AppLocationManager`: Location tracking service

## Core Features Implementation

### Automatic Trip Detection

The app uses CoreMotion and CoreLocation to intelligently detect trips:

```swift
class MotionActivityManager {
    // Monitors device motion to detect trip starts/stops
    // Uses acceleration and speed data for accuracy
    // Implements battery-efficient algorithms
}
```

### Location Tracking

Efficient background location tracking with intelligent updates:

```swift
class AppLocationManager {
    // Handles background location updates
    // Manages location permissions
    // Implements battery-saving strategies
}
```

### Data Storage

CoreData implementation for efficient data management:

```swift
class CoreDataManager {
    // Handles trip and location persistence
    // Manages data relationships
    // Provides efficient querying
}
```

## Testing

The project includes comprehensive unit tests and UI tests:

```bash
# Run tests from command line
xcodebuild test -scheme TrackingApp -destination 'platform=iOS Simulator,name=iPhone 14'
```

Key test areas:
- Trip detection accuracy
- Location tracking reliability
- Data persistence
- UI interactions
- Edge cases handling

## Privacy

The app requires and handles the following permissions:

- Location Services (Always)
- Motion & Fitness Activity
- Background App Refresh

All data is stored locally on the device using CoreData.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- CoreLocation and CoreMotion documentation
- Apple's Human Interface Guidelines

## Contact

Jose Catala - [jfca68@gmail.com]

Project Link: [https://github.com/yourusername/TrackingApp](https://github.com/JFCaBa/TrackingApp)
