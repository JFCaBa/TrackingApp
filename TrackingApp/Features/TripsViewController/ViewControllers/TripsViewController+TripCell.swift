//
//  TripsViewController+TripCell.swift
//  TrackingApp
//
//  Created by Jose on 23/10/2024.
//
//  Purpose: Trip list cell configuration
//  Details: Defines trip list item presentation
//

import UIKit

extension TripsViewController {
    final class TripCell: UITableViewCell {
        // MARK: - UI Components
        
        private let containerView: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = .secondarySystemBackground
            view.layer.cornerRadius = 12
            view.clipsToBounds = true
            return view
        }()
        
        private let dateImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = .systemBlue
            imageView.image = UIImage(systemName: "calendar")
            return imageView
        }()
        
        private let dateLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = .systemFont(ofSize: 16, weight: .medium)
            label.textColor = .label
            return label
        }()
        
        private let timeLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = .systemFont(ofSize: 14)
            label.textColor = .secondaryLabel
            return label
        }()
        
        private let distanceImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = .systemGreen
            imageView.image = UIImage(systemName: "ruler.fill")
            return imageView
        }()
        
        private let distanceLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = .systemFont(ofSize: 14)
            label.textColor = .label
            return label
        }()
        
        private let speedImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = .systemRed
            imageView.image = UIImage(systemName: "speedometer")
            return imageView
        }()
        
        private let speedLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = .systemFont(ofSize: 14)
            label.textColor = .label
            return label
        }()
        
        private let durationLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = .systemFont(ofSize: 14)
            label.textColor = .secondaryLabel
            return label
        }()
        
        private let modeImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = .systemIndigo
            return imageView
        }()
        
        private let modeLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = .systemFont(ofSize: 14, weight: .medium)
            label.textColor = .secondaryLabel
            return label
        }()
        
        
        // MARK: - Initialization
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            setupUI()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - Setup
        
        private func setupUI() {
            selectionStyle = .none
            backgroundColor = .clear
            
            contentView.addSubview(containerView)
            
            let dateStack = UIStackView(arrangedSubviews: [dateImageView, dateLabel])
            dateStack.translatesAutoresizingMaskIntoConstraints = false
            dateStack.spacing = 8
            dateStack.alignment = .center
            
            let modeStack = UIStackView(arrangedSubviews: [modeImageView, modeLabel])
            modeStack.translatesAutoresizingMaskIntoConstraints = false
            modeStack.spacing = 8
            modeStack.alignment = .center
            
            let distanceStack = UIStackView(arrangedSubviews: [distanceImageView, distanceLabel])
            distanceStack.translatesAutoresizingMaskIntoConstraints = false
            distanceStack.spacing = 8
            distanceStack.alignment = .center
            
            let speedStack = UIStackView(arrangedSubviews: [speedImageView, speedLabel])
            speedStack.translatesAutoresizingMaskIntoConstraints = false
            speedStack.spacing = 8
            speedStack.alignment = .center
            
            let statsStack = UIStackView(arrangedSubviews: [distanceStack, speedStack])
            statsStack.translatesAutoresizingMaskIntoConstraints = false
            statsStack.spacing = 16
            statsStack.distribution = .fillEqually
            
            containerView.addSubview(dateStack)
            containerView.addSubview(timeLabel)
            containerView.addSubview(modeStack)
            containerView.addSubview(statsStack)
            containerView.addSubview(durationLabel)
            
            NSLayoutConstraint.activate([
                containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
                
                dateImageView.widthAnchor.constraint(equalToConstant: 20),
                dateImageView.heightAnchor.constraint(equalToConstant: 20),
                
                modeImageView.widthAnchor.constraint(equalToConstant: 20),
                modeImageView.heightAnchor.constraint(equalToConstant: 20),
                
                distanceImageView.widthAnchor.constraint(equalToConstant: 20),
                distanceImageView.heightAnchor.constraint(equalToConstant: 20),
                
                speedImageView.widthAnchor.constraint(equalToConstant: 20),
                speedImageView.heightAnchor.constraint(equalToConstant: 20),
                
                dateStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
                dateStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
                
                timeLabel.centerYAnchor.constraint(equalTo: dateStack.centerYAnchor),
                timeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
                
                modeStack.topAnchor.constraint(equalTo: dateStack.bottomAnchor, constant: 8),
                modeStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
                
                statsStack.topAnchor.constraint(equalTo: modeStack.bottomAnchor, constant: 12),
                statsStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
                statsStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
                
                durationLabel.topAnchor.constraint(equalTo: statsStack.bottomAnchor, constant: 12),
                durationLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
                durationLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
            ])
        }
        
        // MARK: - Configuration
        
        func configure(with trip: Trip) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateLabel.text = dateFormatter.string(from: trip.startDate)
            
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = .short
            timeLabel.text = timeFormatter.string(from: trip.startDate)
            
            // Format distance
            let distance = trip.distance / 1000 // Convert to kilometers
            distanceLabel.text = String(format: "%.1f km", distance)
            
            // Format speed
            speedLabel.text = String(format: "%.0f km/h avg", trip.averageSpeed)
            
            // Calculate and format duration
            let duration = (trip.endDate ?? .now) .timeIntervalSince(trip.startDate)
            let hours = Int(duration) / 3600
            let minutes = Int(duration) / 60 % 60
            
            if hours > 0 {
                durationLabel.text = String(format: "Duration: %dh %dm", hours, minutes)
            } else {
                durationLabel.text = String(format: "Duration: %dm", minutes)
            }
            
            // Configure transportation mode
            modeImageView.image = UIImage(systemName: trip.transportationMode.icon)
            modeImageView.tintColor = trip.transportationMode.color
            modeLabel.text = trip.transportationMode.rawValue.capitalized
        }
        
        override func prepareForReuse() {
            super.prepareForReuse()
            dateLabel.text = nil
            timeLabel.text = nil
            distanceLabel.text = nil
            speedLabel.text = nil
            durationLabel.text = nil
            modeLabel.text = nil
            modeImageView.image = nil
        }
    }
}
