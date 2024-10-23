//
//  TripsViewModel.swift
//  TrackingApp
//
//  Created by Jose on 23/10/2024.
//

import Combine
import Foundation

final class TripsViewModel {
    @Published var state: LoadingState<[Trip]> = .loading
    var cancellables = Set<AnyCancellable>()
}
