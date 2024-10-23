//
//  TripStatCardView.swift
//  TrackingApp
//
//  Created by Jose on 23/10/2024.
//

import UIKit

final class TripStatCardView: UIView {
    // MARK: - UI Components
    
    private let containerStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()
    
    private let headerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()
    
    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let detailsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .label
        return label
    }()
    
    private let distanceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .label
        return label
    }()
    
    private let speedLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .label
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .label
        return label
    }()
    
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
        layer.cornerRadius = 16
        
        addSubview(containerStack)
        
        // Setup header
        headerStack.addArrangedSubview(iconView)
        headerStack.addArrangedSubview(titleLabel)
        
        // Setup details
        detailsStack.addArrangedSubview(dateLabel)
        detailsStack.addArrangedSubview(distanceLabel)
        detailsStack.addArrangedSubview(speedLabel)
        detailsStack.addArrangedSubview(durationLabel)
        
        // Add to main container
        containerStack.addArrangedSubview(headerStack)
        containerStack.addArrangedSubview(detailsStack)
        
        NSLayoutConstraint.activate([
            containerStack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            containerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            containerStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            containerStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        // Add shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.1
    }
    
    // MARK: - Configuration
    
    func configure(title: String, trip: Trip, iconName: String, color: UIColor? = .systemBlue) {
        titleLabel.text = title
        iconView.image = UIImage(systemName: iconName)?.withRenderingMode(.alwaysTemplate)
        iconView.tintColor = color
        
        // Configure date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateLabel.text = "📅 " + dateFormatter.string(from: trip.startDate)
        
        // Configure distance
        let distance = trip.distance / 1000 // Convert to kilometers
        distanceLabel.text = "📍 " + String(format: "%.1f kilometers", distance)
        
        // Configure speed
        speedLabel.text = "⚡️ " + String(format: "%.0f km/h average speed", trip.averageSpeed)
        
        // Configure duration
        let duration = (trip.endDate ?? .now).timeIntervalSince(trip.startDate)
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        
        if hours > 0 {
            durationLabel.text = "⏱ " + String(format: "%dh %dm duration", hours, minutes)
        } else {
            durationLabel.text = "⏱ " + String(format: "%dm duration", minutes)
        }
    }
}

// MARK: - Unit Tests
#if DEBUG
extension TripStatCardView {
    // Expose for testing
    var testLabels: (date: UILabel, distance: UILabel, speed: UILabel, duration: UILabel) {
        return (dateLabel, distanceLabel, speedLabel, durationLabel)
    }
}
#endif
