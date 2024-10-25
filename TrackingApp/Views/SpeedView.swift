//
//  SpeedView.swift
//  TrackingApp
//
//  Created by Jose on 23/10/2024.
//
//  Purpose: Speed display UI component
//  Details: Shows current speed information
//

import UIKit

// MARK: - Speed View
final class SpeedView: UIView {
    private let speedLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let unitLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12)
        label.text = "km/h"
        label.textColor = .white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemBlue
        layer.cornerRadius = 50
        clipsToBounds = true
        
        speedLabel.translatesAutoresizingMaskIntoConstraints = false
        unitLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(speedLabel)
        addSubview(unitLabel)
        
        NSLayoutConstraint.activate([
            speedLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            speedLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10),
            
            unitLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            unitLabel.topAnchor.constraint(equalTo: speedLabel.bottomAnchor, constant: 4)
        ])
    }
    
    func updateSpeed(_ speed: Double) {
        speedLabel.text = String(format: "%.0f", speed)
    }
}
