//
//  MotionActivityManager.swift
//  TrackingApp
//
//  Created by Jose on 23/10/2024.
//

import CoreMotion
import Combine

final class MotionActivityManager {
    static let shared = MotionActivityManager()
    
    private let activityManager = CMMotionActivityManager()
    private let motionManager = CMMotionManager()
    private let pedometer = CMPedometer()
    
    @Published private(set) var currentActivity: CMMotionActivity?
    @Published private(set) var isInVehicle = false
    
    private var timer: Timer?
    private var lastSignificantMotion: Date?
    private let requiredStationaryTime: TimeInterval = 300 // 5 minutes
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupMotionUpdates()
    }
    
    func startMonitoring() {
        guard CMMotionActivityManager.isActivityAvailable() else {
            print("Motion activity not available")
            return
        }
        
        activityManager.startActivityUpdates(to: .main) { [weak self] activity in
            guard let activity = activity else { return }
            self?.handleActivityUpdate(activity)
        }
        
        motionManager.startDeviceMotionUpdates()
        startAccelerometerUpdates()
    }
    
    func stopMonitoring() {
        activityManager.stopActivityUpdates()
        motionManager.stopDeviceMotionUpdates()
        motionManager.stopAccelerometerUpdates()
    }
    
    private func setupMotionUpdates() {
        // Configure accelerometer
        motionManager.accelerometerUpdateInterval = 1.0
        
        // Configure activity threshold values
        NotificationCenter.default.publisher(for: .locationSpeedDidUpdate)
            .compactMap { $0.object as? Double }
            .sink { [weak self] speed in
                self?.handleSpeedUpdate(speed)
            }
            .store(in: &cancellables)
    }
    
    private func startAccelerometerUpdates() {
        guard motionManager.isAccelerometerAvailable else { return }
        
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let data = data else { return }
            self?.handleAccelerometerData(data)
        }
    }
    
    private func handleActivityUpdate(_ activity: CMMotionActivity) {
        currentActivity = activity
        
        if activity.automotive {
            if !isInVehicle {
                considerTripStart()
            }
        } else if activity.stationary {
            if isInVehicle {
                considerTripEnd()
            }
        }
    }
    
    private func handleSpeedUpdate(_ speed: Double) {
        // Convert speed from m/s to km/h
        let speedKmh = speed * 3.6
        
        if speedKmh > 20 { // More than 20 km/h indicates vehicle motion
            if !isInVehicle {
                considerTripStart()
            }
        } else if speedKmh < 5 { // Less than 5 km/h might indicate stop
            if isInVehicle {
                lastSignificantMotion = Date()
                startStationaryTimer()
            }
        }
    }
    
    private func handleAccelerometerData(_ data: CMAccelerometerData) {
        // Calculate total acceleration magnitude
        let acceleration = sqrt(pow(data.acceleration.x, 2) +
                             pow(data.acceleration.y, 2) +
                             pow(data.acceleration.z, 2))
        
        if acceleration > 0.1 { // Threshold for significant motion
            lastSignificantMotion = Date()
        }
    }
    
    private func considerTripStart() {
        isInVehicle = true
        NotificationCenter.default.post(name: .tripShouldStart, object: nil)
    }
    
    public func considerTripEnd() {
        guard isInVehicle else { return }
        
        if let lastMotion = lastSignificantMotion,
           Date().timeIntervalSince(lastMotion) >= requiredStationaryTime {
            isInVehicle = false
            NotificationCenter.default.post(name: .tripShouldEnd, object: nil)
        }
    }
    
    private func startStationaryTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.considerTripEnd()
        }
    }
}

// MARK: - Notification Extensions
extension Notification.Name {
    static let tripShouldStart = Notification.Name("tripShouldStart")
    static let tripShouldEnd = Notification.Name("tripShouldEnd")
    static let locationSpeedDidUpdate = Notification.Name("locationSpeedDidUpdate")
}
