//
//  StatisticsViewController.swift
//  TrackingApp
//
//  Created by Jose on 23/10/2024.
//

import Combine
import UIKit

final class StatisticsViewController: UIViewController {
    private let viewModel: StatisticsViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var loadingView: LoadingView = {
        let view = LoadingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var emptyStateView: EmptyStateView = {
        let view = EmptyStateView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let statsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        return stackView
    }()
    
    // MARK: - Initialization
    
    init(viewModel: StatisticsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.loadStatistics()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Statistics"
        
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(statsStackView)
        view.addSubview(loadingView)
        view.addSubview(emptyStateView)
        
        emptyStateView.configure(
            image: UIImage(systemName: "chart.bar.xaxis"),
            title: "No Statistics Yet",
            message: "Complete your first trip to see your statistics here!"
        )
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            statsStackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            statsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            statsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            statsStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateView.topAnchor.constraint(equalTo: view.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Bindings

    private func setupBindings() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .print("State Publisher")
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.handleState(state)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - State Handling
    
    private func handleState(_ state: LoadingState<StatisticsViewModel.Statistics>) {
        switch state {
        case .loading:
            showLoadingView()
        case .loaded(let statistics):
            showStatistics(statistics)
        case .empty:
            showEmptyState()
        case .error(let error):
            showError(error)
        }
    }
    
    private func showLoadingView() {
        loadingView.startAnimating()
        loadingView.isHidden = false
        emptyStateView.isHidden = true
        statsStackView.isHidden = true
    }
    
    func addSectionHeader(_ title: String) {
        let headerView = createSectionHeaderView(title)
        statsStackView.addArrangedSubview(headerView)
    }
        
    private func createSectionHeaderView(_ title: String) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
            
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .label
            
        let separatorLine = UIView()
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        separatorLine.backgroundColor = .separator
            
        containerView.addSubview(titleLabel)
        containerView.addSubview(separatorLine)
            
        NSLayoutConstraint.activate([
            // Title constraints
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
                
            // Separator constraints
            separatorLine.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            separatorLine.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 1),
            separatorLine.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])
            
        return containerView
    }
    
    private func addModeStatistics(_ modeStats: [StatisticsViewModel.ModeStatistics]) {
        let modeStackView = UIStackView()
        modeStackView.axis = .vertical
        modeStackView.spacing = 16
        
        for modeStat in modeStats {
            let card = StatCardView()
            card.configure(
                title: "\(modeStat.mode.rawValue.capitalized) Trips",
                value: """
                \(modeStat.tripCount) trips
                \(String(format: "%.1f km", modeStat.totalDistance / 1000))
                \(String(format: "%.0f km/h avg", modeStat.averageSpeed))
                """,
                iconName: modeStat.mode.icon,
                color: modeStat.mode.color
            )
            modeStackView.addArrangedSubview(card)
        }
        
        statsStackView.addArrangedSubview(modeStackView)
    }
    
    private func showStatistics(_ statistics: StatisticsViewModel.Statistics) {
        loadingView.stopAnimating()
        loadingView.isHidden = true
        emptyStateView.isHidden = true
        statsStackView.isHidden = false
        
        // Clear existing stats
        statsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Overview Section
        addSectionHeader("Overview")
        
        // Add stats cards
        addStatCard(
            title: "Total Trips",
            value: "\(statistics.totalTrips)",
            icon: "number.circle.fill",
            color: .systemBlue
        )
        
        addStatCard(
            title: "Total Distance",
            value: String(format: "%.1f km", statistics.totalDistance / 1000),
            icon: "ruler.fill",
            color: .systemGreen
        )
        
        addStatCard(
            title: "Average Speed",
            value: String(format: "%.0f km/h", statistics.averageSpeed),
            icon: "speedometer",
            color: .systemOrange
        )
        
        // Format total duration
        let hours = Int(statistics.totalDuration) / 3600
        let minutes = Int(statistics.totalDuration / 60) % 60
        addStatCard(
            title: "Total Duration",
            value: String(format: "%dh %dm", hours, minutes),
            icon: "clock.fill",
            color: .systemPurple
        )
        
        // Add longest trip card if available
        if let longestTrip = statistics.longestTrip {
            addTripCard(
                title: "Longest Trip",
                trip: longestTrip,
                icon: "arrow.up.right.circle.fill",
                color: .systemIndigo
            )
        }
        
        // Add fastest trip card if available
        if let fastestTrip = statistics.fastestTrip {
            addTripCard(
                title: "Fastest Trip",
                trip: fastestTrip,
                icon: "bolt.circle.fill",
                color: .systemRed
            )
        }
        
        if !statistics.modeStats.isEmpty {
            addSectionHeader("By Transportation Mode")
            addModeStatistics(statistics.modeStats)
        }
    }
    
    // MARK: - Helpers
    
    private func showEmptyState() {
        loadingView.stopAnimating()
        loadingView.isHidden = true
        emptyStateView.isHidden = false
        statsStackView.isHidden = true
    }
    
    private func showError(_ error: Error) {
        loadingView.stopAnimating()
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.viewModel.loadStatistics()
        })
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }
    
    private func addStatCard(title: String, value: String, icon: String, color: UIColor) {
        let card = StatCardView()
        card.configure(title: title, value: value, iconName: icon, color: color)
        statsStackView.addArrangedSubview(card)
    }
    
    private func addTripCard(title: String, trip: Trip, icon: String, color: UIColor) {
        let card = TripStatCardView()
        card.configure(title: title, trip: trip, iconName: icon, color: color)
        statsStackView.addArrangedSubview(card)
    }
}
