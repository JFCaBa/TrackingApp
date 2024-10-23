//
//  TripStatsView.swift
//  TrackingApp
//
//  Created by Jose on 23/10/2024.
//

import UIKit

// TripStatsView.swift
final class TripStatsView: UIView {
    // MARK: - UI Components
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        stack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        stack.isLayoutMarginsRelativeArrangement = true
        return stack
    }()
    
    private let dateLabel = UILabel()
    private let distanceLabel = UILabel()
    private let durationLabel = UILabel()
    private let speedLabel = UILabel()
    private let transportModeLabel = UILabel()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .secondarySystemBackground
        
        addSubview(stackView)
        [dateLabel, distanceLabel, durationLabel, speedLabel, transportModeLabel].forEach {
            $0.font = .systemFont(ofSize: 16)
            stackView.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(with trip: Trip) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateLabel.text = "📅 Date: " + dateFormatter.string(from: trip.startDate)
        
        distanceLabel.text = "📍 Distance: " + String(format: "%.1f km", trip.distance / 1000)
        
        let duration = (trip.endDate ?? .now).timeIntervalSince(trip.startDate)
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        durationLabel.text = "⏱ Duration: " + String(format: "%dh %dm", hours, minutes)
        
        speedLabel.text = "⚡️ Average Speed: " + String(format: "%.0f km/h", trip.averageSpeed)
        
        transportModeLabel.text = "🚗 Mode: " + trip.transportationMode.displayName
    }
}
