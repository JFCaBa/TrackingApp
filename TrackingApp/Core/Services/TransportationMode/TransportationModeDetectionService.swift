//
//  TransportationModeDetectionService.swift
//  TrackingApp
//
//  Created by Jose on 23/10/2024.
//

import CoreMotion
import Combine
import CoreLocation

final class TransportationModeDetectionService {
    // MARK: - Properties
    
    static let shared = TransportationModeDetectionService()
    
    @Published private(set) var currentMode: TransportationMode = .unknown
    private let activityManager = CMMotionActivityManager()
    private var cancellables = Set<AnyCancellable>()
    
    // Detection parameters
    private let highConfidenceThreshold = 0.8
    private let mediumConfidenceThreshold = 0.5
    private let modeSwitchingDelay: TimeInterval = 10 // Seconds to wait before switching modes
    private var lastModeChangeTime: Date = .distantPast
    
    // Mode confidence tracking
    private var modeConfidences: [TransportationMode: Double] = [:]
    private var consecutiveModeDetections: [TransportationMode: Int] = [:]
    private let requiredConsecutiveDetections = 3
    
    // MARK: - Initialization
    
    private init() {
        setupSubscriptions()
    }
    
    // MARK: - Public Methods
    
    func startMonitoring() {
        guard CMMotionActivityManager.isActivityAvailable() else {
            print("Motion activity not available")
            return
        }
        
        activityManager.startActivityUpdates(to: .main) { [weak self] activity in
            guard let activity = activity else { return }
            self?.processActivityUpdate(activity)
        }
    }
    
    func stopMonitoring() {
        activityManager.stopActivityUpdates()
    }
    
    // MARK: - Private Methods
    
    private func setupSubscriptions() {
        NotificationCenter.default.publisher(for: .locationSpeedDidUpdate)
            .compactMap { $0.object as? Double }
            .sink { [weak self] speed in
                self?.processSpeedUpdate(speed)
            }
            .store(in: &cancellables)
    }
    
    private func processActivityUpdate(_ activity: CMMotionActivity) {
        var activityConfidence = 0.0
        var detectedMode: TransportationMode = .unknown
        
        switch (activity.automotive, activity.cycling, activity.walking) {
        case (true, _, _) where activity.confidence == .high:
            detectedMode = .automotive
            activityConfidence = 0.8
        case (_, true, _) where activity.confidence == .high:
            detectedMode = .cycling
            activityConfidence = 0.7
        case (_, _, true) where activity.confidence == .high:
            detectedMode = .walking
            activityConfidence = 0.9
        default:
            detectedMode = .unknown
            activityConfidence = 0.2
        }
        
        updateConfidence(for: detectedMode, with: activityConfidence)
    }
    
    private func processSpeedUpdate(_ speed: Double) {
        let speedKmh = speed * 3.6 // Convert m/s to km/h
        let speedBasedMode = TransportationMode.detect(speed: speed)
        
        var speedConfidence = 0.0
        switch speedKmh {
        case 0..<7:
            speedConfidence = speedBasedMode == .walking ? 0.9 : 0.3
        case 7..<25:
            speedConfidence = speedBasedMode == .cycling ? 0.8 : 0.4
        case 25...:
            speedConfidence = speedBasedMode == .automotive ? 0.95 : 0.5
        default:
            speedConfidence = 0.2
        }
        
        updateConfidence(for: speedBasedMode, with: speedConfidence)
    }
    
    private func updateConfidence(for mode: TransportationMode, with confidence: Double) {
        // Update running confidence for the mode
        let currentConfidence = modeConfidences[mode] ?? 0.0
        modeConfidences[mode] = (currentConfidence + confidence) / 2.0
        
        // Increment consecutive detections for this mode
        consecutiveModeDetections[mode] = (consecutiveModeDetections[mode] ?? 0) + 1
        
        // Reset consecutive detections for other modes
        TransportationMode.allCases.forEach { otherMode in
            if otherMode != mode {
                consecutiveModeDetections[otherMode] = 0
            }
        }
        
        // Check if we should update the current mode
        if shouldUpdateMode(to: mode) {
            updateTransportationMode(mode)
        }
        
        // Decay confidences for other modes
        decayConfidences(except: mode)
    }
    
    private func shouldUpdateMode(to newMode: TransportationMode) -> Bool {
        guard let confidence = modeConfidences[newMode],
              let consecutiveDetections = consecutiveModeDetections[newMode]
        else { return false }
        
        let timeElapsedSinceLastChange = Date().timeIntervalSince(lastModeChangeTime)
        
        return (confidence >= highConfidenceThreshold &&
                consecutiveDetections >= requiredConsecutiveDetections &&
                timeElapsedSinceLastChange >= modeSwitchingDelay) ||
               (confidence >= mediumConfidenceThreshold &&
                currentMode == .unknown &&
                consecutiveDetections >= requiredConsecutiveDetections)
    }
    
    private func updateTransportationMode(_ newMode: TransportationMode) {
        guard currentMode != newMode else { return }
        
        currentMode = newMode
        lastModeChangeTime = Date()
        
        NotificationCenter.default.post(
            name: .transportationModeDidChange,
            object: newMode
        )
    }
    
    private func decayConfidences(except activeMode: TransportationMode) {
        let decayFactor = 0.9
        TransportationMode.allCases.forEach { mode in
            if mode != activeMode {
                modeConfidences[mode] = (modeConfidences[mode] ?? 0) * decayFactor
            }
        }
    }
}

// MARK: - Testing Extensions

#if DEBUG
extension TransportationModeDetectionService {
    func testProcessSpeed(_ speed: Double) {
        processSpeedUpdate(speed)
    }
    
    func testProcessActivity(_ activity: CMMotionActivity) {
        processActivityUpdate(activity)
    }
    
    var testCurrentMode: TransportationMode {
        currentMode
    }
    
    var testModeConfidences: [TransportationMode: Double] {
        modeConfidences
    }
    
    func testResetState() {
        currentMode = .unknown
        modeConfidences.removeAll()
        consecutiveModeDetections.removeAll()
        lastModeChangeTime = .distantPast
    }
}
#endif
