//
//  TripsViewController.swift
//  TrackingApp
//
//  Created by Jose on 23/10/2024.
//

import Combine
import UIKit

final class TripsViewController: UIViewController {
    private let viewModel: TripsViewModel
    private let tableView = UITableView()
    private var cancellables = Set<AnyCancellable>()
    weak var coordinator: TripsCoordinator?
    
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
    
    // MARK: - Initialization
    
    init(viewModel: TripsViewModel) {
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
        viewModel.loadTrips()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        setupTableView()
        setupLoadingView()
        setupEmptyStateView()
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(TripCell.self, forCellReuseIdentifier: "TripCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 88
        tableView.tableFooterView = UIView()
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupLoadingView() {
        view.addSubview(loadingView)
        
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupEmptyStateView() {
        view.addSubview(emptyStateView)
        
        NSLayoutConstraint.activate([
            emptyStateView.topAnchor.constraint(equalTo: view.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        emptyStateView.configure(
            image: UIImage(systemName: "car.fill"),
            title: "No Trips Yet",
            message: "Your recorded trips will appear here. Start driving to automatically record your first trip!"
        )
    }
    
    private func setupBindings() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] state in
                guard let self else { return }
                
                handleState(state)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - State Handling
    
    private func handleState(_ state: LoadingState<[Trip]>) {
        switch state {
        case .loading:
            showLoadingView()
        case .loaded(let trips):
            showTrips(trips)
        case .empty:
            showEmptyState()
        case .error(let error):
            showError(error)
        }
    }
    
    // MARK: - Helpers
    
    private func showLoadingView() {
        loadingView.startAnimating()
        loadingView.isHidden = false
        emptyStateView.isHidden = true
        tableView.isHidden = true
    }
    
    private func showTrips(_ trips: [Trip]) {
        loadingView.stopAnimating()
        loadingView.isHidden = true
        emptyStateView.isHidden = true
        tableView.isHidden = false
        tableView.reloadData()
    }
    
    private func showEmptyState() {
        loadingView.stopAnimating()
        loadingView.isHidden = true
        emptyStateView.isHidden = false
        tableView.isHidden = true
    }
    
    private func showError(_ error: Error) {
        loadingView.stopAnimating()
        loadingView.isHidden = true
        
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.viewModel.loadTrips()
        })
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension TripsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if case .loaded(let trips) = viewModel.state {
            return trips.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath) as? TripCell,
              case .loaded(let trips) = viewModel.state
        else {
            return UITableViewCell()
        }
        
        cell.configure(with: trips[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate

extension TripsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard case .loaded(let trips) = viewModel.state,
              editingStyle == .delete
        else {
            return
        }
        
        viewModel.deleteTrip(trips[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard case .loaded(let trips) = viewModel.state else { return }
        let trip = trips[indexPath.row]
        coordinator?.showTripDetails(for: trip)
    }
}
