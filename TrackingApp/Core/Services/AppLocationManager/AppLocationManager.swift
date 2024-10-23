import Combine
import CoreLocation
import UIKit

final class AppLocationManager: NSObject {
    // MARK: - Properties
    
    static let shared = AppLocationManager()
    
    @Published private(set) var currentLocation: CLLocation?
    @Published private(set) var locationAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isTracking = false
    @Published private(set) var currentSpeed: Double = 0.0
    @Published private(set) var averageSpeed: Double = 0.0
    
    private let locationManager = CLLocationManager()
    public var cancellables = Set<AnyCancellable>()
    
    // Constants for location tracking
    private let significantDistanceChange: Double = 10.0 // meters
    private let minimumAccuracy: Double = 20.0 // meters
    private let stationaryThreshold: TimeInterval = 300 // 5 minutes
    private var lastSignificantMovement: Date?
    
    // Speed tracking
    private var speedReadings: [Double] = []
    private let maxSpeedReadings = 10 // For calculating rolling average
    
    // MARK: - Initialization
    
    override private init() {
        super.init()
        setupLocationManager()
        setupTransportationModeObserver()
    }
    
    // MARK: - Setup
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = significantDistanceChange
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.activityType = .automotiveNavigation
        
        // Register for background location updates
        if UIApplication.shared.applicationState == .background {
            locationManager.startMonitoringSignificantLocationChanges()
        }
    }
    
    private func setupTransportationModeObserver() {
        // Observe transportation mode changes
        NotificationCenter.default.publisher(for: .transportationModeDidChange)
            .compactMap { $0.object as? TransportationMode }
            .sink { [weak self] mode in
                self?.handleTransportationModeChange(mode)
            }
            .store(in: &cancellables)
        
        // Observe app lifecycle changes
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { [weak self] _ in
                self?.handleAppDidEnterBackground()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                self?.handleAppWillEnterForeground()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    func startUpdatingLocation() {
        locationAuthorizationStatus = locationManager.authorizationStatus
        
        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            TransportationModeDetectionService.shared.startMonitoring()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            NotificationCenter.default.post(name: .locationPermissionDenied, object: nil)
        @unknown default:
            break
        }
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        TransportationModeDetectionService.shared.stopMonitoring()
        endTrackingIfNeeded()
    }
    
    // MARK: - Private Methods
    
    private func handleTransportationModeChange(_ mode: TransportationMode) {
        switch mode {
        case .automotive:
            startTrackingIfNeeded()
        case .unknown, .walking, .cycling:
            checkForTripEnd()
        }
    }
    
    private func startTrackingIfNeeded() {
        guard !isTracking else { return }
        
        isTracking = true
        lastSignificantMovement = Date()
        speedReadings.removeAll() // Reset speed readings for new trip
        CoreDataManager.shared.startNewTrip()
    }
    
    private func checkForTripEnd() {
        guard isTracking else { return }
        
        // End trip if we've been stationary for too long
        if let lastMovement = lastSignificantMovement,
           Date().timeIntervalSince(lastMovement) >= stationaryThreshold {
            endTrackingIfNeeded()
        }
    }
    
    private func endTrackingIfNeeded() {
        guard isTracking else { return }
        
        isTracking = false
        lastSignificantMovement = nil
        speedReadings.removeAll()
        currentSpeed = 0.0
        averageSpeed = 0.0
        CoreDataManager.shared.endCurrentTrip()
    }
    
    private func handleAppDidEnterBackground() {
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    private func handleAppWillEnterForeground() {
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.startUpdatingLocation()
    }
    
    private func updateLastSignificantMovement(_ location: CLLocation) {
        // Update last movement time if accuracy is good enough
        if location.horizontalAccuracy <= minimumAccuracy {
            lastSignificantMovement = Date()
        }
    }
    
    private func updateSpeed(_ location: CLLocation) {
        // Convert speed from m/s to km/h and ensure non-negative
        let speedInKmh = max(0, location.speed * 3.6)
        currentSpeed = speedInKmh
        
        // Update rolling average
        speedReadings.append(speedInKmh)
        if speedReadings.count > maxSpeedReadings {
            speedReadings.removeFirst()
        }
        
        averageSpeed = speedReadings.reduce(0, +) / Double(speedReadings.count)
        
        NotificationCenter.default.post(name: .locationSpeedDidUpdate, object: speedInKmh)
        
        // Check for potential parking if speed is very low
        if speedInKmh < 1.0 {
            checkForTripEnd()
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension AppLocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        currentLocation = location
        updateSpeed(location)
        
        // Post notifications for other components
        NotificationCenter.default.post(name: .locationDidUpdate, object: location)
        
        if isTracking {
            updateLastSignificantMovement(location)
            CoreDataManager.shared.addLocation(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationAuthorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            startUpdatingLocation()
        case .denied, .restricted:
            stopUpdatingLocation()
            NotificationCenter.default.post(name: .locationPermissionDenied, object: nil)
        default:
            break
        }
    }
}

// MARK: - Testing Extensions

#if DEBUG
extension AppLocationManager {
    var testIsTracking: Bool {
        isTracking
    }
    
    func testSetTracking(_ tracking: Bool) {
        isTracking = tracking
    }
    
    func testResetState() {
        isTracking = false
        lastSignificantMovement = nil
        currentLocation = nil
        currentSpeed = 0.0
        averageSpeed = 0.0
        speedReadings.removeAll()
    }
    
    func testSetSpeed(_ speed: Double) {
        guard let location = currentLocation else { return }
        let testLocation = CLLocation(
            coordinate: location.coordinate,
            altitude: location.altitude,
            horizontalAccuracy: location.horizontalAccuracy,
            verticalAccuracy: location.verticalAccuracy,
            course: location.course,
            speed: speed,
            timestamp: Date()
        )
        updateSpeed(testLocation)
    }
}
#endif
