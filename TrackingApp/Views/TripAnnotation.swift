//
//  TripAnnotation.swift
//  TrackingApp
//
//  Created by Jose on 23/10/2024.
//

import CoreLocation
import MapKit
import UIKit

// TripAnnotation.swift
final class TripAnnotation: NSObject, MKAnnotation {
    enum AnnotationType {
        case start
        case end
    }
    
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let type: AnnotationType
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, type: AnnotationType) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.type = type
        super.init()
    }
}
