//
//  TripMapViewController.swift
//  TrackingApp
//
//  Created by Jose on 23/10/2024.
//
//  Purpose: Individual trip map view controller
//  Details: Shows detailed trip route and information
//

import UIKit
import MapKit
import Combine

final class TripMapViewController: UIViewController {
    // MARK: - Properties
    
    private let viewModel: TripMapViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private let mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        map.showsUserLocation = false
        return map
    }()
    
    private let statsView: TripStatsView = {
        let view = TripStatsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let loadingView: LoadingView = {
        let view = LoadingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initialization
    
    init(viewModel: TripMapViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        mapView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.loadTripDetails()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Trip Details"
        
        view.addSubview(mapView)
        view.addSubview(statsView)
        view.addSubview(loadingView)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7),
            
            statsView.topAnchor.constraint(equalTo: mapView.bottomAnchor),
            statsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            statsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            statsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleState(state)
            }
            .store(in: &cancellables)
    }
    
    private func handleState(_ state: LoadingState<TripMapViewModel.TripDetails>) {
        switch state {
        case .loading:
            showLoadingView()
        case .loaded(let details):
            showTripDetails(details)
        case .empty:
            showEmptyState()
        case .error(let error):
            showError(error)
        }
    }
    
    private func showLoadingView() {
        loadingView.startAnimating()
        loadingView.isHidden = false
        mapView.isHidden = true
        statsView.isHidden = true
    }
    
    private func showTripDetails(_ details: TripMapViewModel.TripDetails) {
        loadingView.stopAnimating()
        loadingView.isHidden = true
        mapView.isHidden = false
        statsView.isHidden = false
        
        // Update map
        addRouteOverlay(for: details.routeCoordinates)
        centerMapOnRoute(details.routeCoordinates)
        
        // Update stats
        statsView.configure(with: details.trip)
    }
    
    private func showEmptyState() {
        loadingView.stopAnimating()
        showError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No trip data available"]))
    }
    
    private func showError(_ error: Error) {
        loadingView.stopAnimating()
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func addRouteOverlay(for coordinates: [CLLocationCoordinate2D]) {
        mapView.removeOverlays(mapView.overlays)
        
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polyline)
        
        // Add start and end annotations
        if let first = coordinates.first, let last = coordinates.last {
            let startAnnotation = TripAnnotation(
                coordinate: first,
                title: "Start",
                subtitle: nil,
                type: .start
            )
            
            let endAnnotation = TripAnnotation(
                coordinate: last,
                title: "End",
                subtitle: nil,
                type: .end
            )
            
            mapView.addAnnotations([startAnnotation, endAnnotation])
        }
    }
    
    private func centerMapOnRoute(_ coordinates: [CLLocationCoordinate2D]) {
        let rect = coordinates.reduce(MKMapRect.null) { rect, coordinate in
            let point = MKMapPoint(coordinate)
            let pointRect = MKMapRect(x: point.x, y: point.y, width: 0, height: 0)
            return rect.union(pointRect)
        }
        
        let insets = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
        mapView.setVisibleMapRect(rect, edgePadding: insets, animated: true)
    }
}

// MARK: - MKMapViewDelegate

extension TripMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 4
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let tripAnnotation = annotation as? TripAnnotation else { return nil }
        
        let identifier = "TripAnnotation"
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        
        switch tripAnnotation.type {
        case .start:
            annotationView.markerTintColor = .systemGreen
            annotationView.glyphImage = UIImage(systemName: "flag.fill")
        case .end:
            annotationView.markerTintColor = .systemRed
            annotationView.glyphImage = UIImage(systemName: "flag.checkered")
        }
        
        return annotationView
    }
}

