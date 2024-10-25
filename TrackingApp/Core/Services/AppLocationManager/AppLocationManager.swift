//
//  AppLocationManager.swift
//  TrackingApp
//
//  Created by Jose on 23/10/2024.
//
//  Purpose: Core location management service
//  Details: Handles location tracking, updates, and background location services
//

import BackgroundTasks
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
    private let stationaryThreshold: TimeInterval = 60 // 1 minute
    private var lastSignificantMovement: Date?
    
    // Speed tracking
    private var speedReadings: [Double] = []
    private let maxSpeedReadings = 10 // For calculating rolling average
    
    // Background task
    private let backgroundTaskIdentifier = "com.app.location.refresh"
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    // MARK: - Initialization
    
    override private init() {
        super.init()
        setupLocationManager()
        setupTransportationModeObserver()
        registerBackgroundTask()
    }
    
    // MARK: - Setup
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.distanceFilter = significantDistanceChange
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.activityType = .automotiveNavigation
        
        // If phone is charging use BestForNavigation (following Apple guidelines)
        // This mode takes more power and should be used just when charging or full charged
        if isPhoneCharging() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        }
        else {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
        
        // Register for background location updates
//        if UIApplication.shared.applicationState == .background {
            locationManager.startMonitoringSignificantLocationChanges()
//        }
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
        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
        case .authorizedAlways:
            startLocationServices()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            NotificationCenter.default.post(name: .locationPermissionDenied, object: nil)
        @unknown default:
            break
        }
    }
    
    func startNewTrip() {
        isTracking = true
        GeofencingService.shared.removeAllGeofences()
        CoreDataManager.shared.startNewTrip()
    }
    
    func endCurrentTrip(at location: CLLocation?) {
        guard let location else { return }
        isTracking = false
        GeofencingService.shared.createGeofenceForParkedLocation(location)
        CoreDataManager.shared.endCurrentTrip()
    }
    
    // MARK: - Background Task
    
    private func registerBackgroundTask() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: backgroundTaskIdentifier,
            using: nil
        ) { task in
            self.handleBackgroundTask(task as! BGAppRefreshTask)
        }
    }
    
    private func handleBackgroundTask(_ task: BGAppRefreshTask) {
        scheduleBackgroundTask()
        
        task.expirationHandler = {
            // Clean up background task if needed
            task.setTaskCompleted(success: false)
        }
        
        // Keep location updates running in background
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        
        // Give enough time for location update
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            task.setTaskCompleted(success: true)
        }
    }
    
    private func beginBackgroundTask() {
        guard backgroundTask == .invalid else { return }
        
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
    }
    
    private func scheduleBackgroundTask() {
        let request = BGAppRefreshTaskRequest(identifier: backgroundTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule background task: \(error)")
        }
    }
    
    private func endBackgroundTask() {
        guard backgroundTask != .invalid else { return }
        
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }
    
    // MARK: - Location
    
    private func startLocationServices() {
        beginBackgroundTask()
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        scheduleBackgroundTask()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        endTrackingIfNeeded()
        endBackgroundTask()
    }
    
    fileprivate func isPhoneCharging() -> Bool{
        UIDevice.current.isBatteryMonitoringEnabled = true
        let state = UIDevice.current.batteryState
        
        if state == .charging || state == .full {
            return true
        }
        
        return false
    }
    
    private func handleTransportationModeChange(_ mode: TransportationMode) {
        switch mode {
        case .automotive:
            startTrackingIfNeeded()
        case .unknown, .walking, .cycling:
            checkForTripEnd()
        }
    }
    
    // MARK: - Tracking
    
    private func startTrackingIfNeeded() {
        guard !isTracking else { return }
        
        isTracking = true
        lastSignificantMovement = Date()
        speedReadings.removeAll() // Reset speed readings for new trip
        CoreDataManager.shared.startNewTrip()
        locationManager.showsBackgroundLocationIndicator = true
    }
    
    private func endTrackingIfNeeded() {
        guard isTracking else { return }
        
        isTracking = false
        lastSignificantMovement = nil
        speedReadings.removeAll()
        currentSpeed = 0.0
        averageSpeed = 0.0
        endCurrentTrip(at: currentLocation)
        CoreDataManager.shared.endCurrentTrip()
        locationManager.showsBackgroundLocationIndicator = false
    }
    
    private func checkForTripEnd() {
        guard isTracking else { return }
        
        // End trip if we've been stationary for too long
        if let lastMovement = lastSignificantMovement,
           Date().timeIntervalSince(lastMovement) >= stationaryThreshold {
            endTrackingIfNeeded()
        }
    }
    
    // MARK: - Notifications
    
    private func handleAppDidEnterBackground() {
        beginBackgroundTask() 
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    private func handleAppWillEnterForeground() {
        startUpdatingLocation()
    }
    
    // MARK: - Helpers
    
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
        endTrackingIfNeeded()
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        print("Location updates paused.")
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        print("Location updates resumed.")
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
