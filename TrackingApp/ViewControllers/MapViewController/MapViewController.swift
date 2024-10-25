//
//  MapViewController.swift
//  TrackingApp
//
//  Created by Jose on 23/10/2024.
//
//  Purpose: Map screen view controller
//  Details: Handles map display and user interaction
//

import Combine
import MapKit
import UIKit

final class MapViewController: UIViewController {
    private let viewModel: MapViewModel
    private let mapView = MKMapView()
    private let speedView = SpeedView()
    private var cancellables = Set<AnyCancellable>()
    private var isInitialLocation = true
    private var userTrackingButton: MKUserTrackingButton!
    
    // MARK: - Initialization
    
    init(viewModel: MapViewModel) {
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
        setupMap()
        setupUI()
        setupBindings()
        setupNotificationObservers()
        checkLocationPermissions()
    }
    
    // MARK: - Setup
    
    private func setupMap() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        // Configure map for smooth tracking
        mapView.userTrackingMode = .followWithHeading
        mapView.camera.altitude = 1000
        mapView.cameraBoundary = nil
        
        // Add tracking button
        userTrackingButton = MKUserTrackingButton(mapView: mapView)
        userTrackingButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure map appearance
        mapView.pointOfInterestFilter = .excludingAll
        mapView.showsCompass = true
        mapView.showsScale = true
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        speedView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(mapView)
        view.addSubview(speedView)
        view.addSubview(userTrackingButton)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            speedView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            speedView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            speedView.widthAnchor.constraint(equalToConstant: 100),
            speedView.heightAnchor.constraint(equalToConstant: 100),
            
            userTrackingButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            userTrackingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupBindings() {
        viewModel.$currentSpeed
            .receive(on: DispatchQueue.main)
            .sink { [weak self] speed in
                guard let self else { return }
                speedView.updateSpeed(speed)
            }
            .store(in: &cancellables)
        
        viewModel.$currentLocation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                guard let self, let location = location else { return }
                handleLocationUpdate(location)
            }
            .store(in: &cancellables)
            
        LocationPermissionChecker.shared.$authorizationStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self else { return }
                handleLocationAuthorizationChange(status)
            }
            .store(in: &cancellables)
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLocationPermissionDenied),
            name: .locationPermissionDenied,
            object: nil
        )
    }
    
    // MARK: - Location Handling
    
    private func handleLocationUpdate(_ location: CLLocation) {
        if isInitialLocation {
            centerMapOnInitialLocation(location)
            isInitialLocation = false
        }
    }
    
    private func centerMapOnInitialLocation(_ location: CLLocation) {
        let region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 1000,
            longitudinalMeters: 1000
        )
        mapView.setRegion(region, animated: true)
    }
    
    private func checkLocationPermissions() {
        LocationPermissionChecker.shared.requestLocationPermissions()
    }
    
    private func handleLocationAuthorizationChange(_ status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            LocationPermissionAlert.showBackgroundLocationAlert(on: self)
        case .denied, .restricted:
            LocationPermissionAlert.showPermissionDeniedAlert(on: self)
        default:
            break
        }
    }
    
    @objc private func handleLocationPermissionDenied() {
        LocationPermissionAlert.showPermissionDeniedAlert(on: self)
    }
}

// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard let userLocation = userLocation.location else { return }
        guard isInitialLocation else { return }
        centerMapOnInitialLocation(userLocation)
        isInitialLocation = false
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        // Handle region change start if needed
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // Handle region change completion if needed
    }
}
