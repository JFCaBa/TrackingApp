//
//  LocationPermissionAlert.swift
//  TrackingApp
//
//  Created by Jose on 23/10/2024.
//

import UIKit

final class LocationPermissionAlert {
    
    static func showPermissionDeniedAlert(on viewController: UIViewController) {
        let alert = UIAlertController(
            title: "Location Access Required",
            message: "This app needs location access to track your trips. Please enable it in Settings.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            LocationPermissionChecker.shared.openAppSettings()
        })
        
        viewController.present(alert, animated: true)
    }
    
    static func showBackgroundLocationAlert(on viewController: UIViewController) {
        let alert = UIAlertController(
            title: "Background Location",
            message: "To track your trips in the background, please allow 'Always' location access in the next prompt.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Continue", style: .default) { _ in
            LocationPermissionChecker.shared.requestLocationPermissions()
        })
        
        viewController.present(alert, animated: true)
    }
}
