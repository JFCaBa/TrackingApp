//
//  LoadingState.swift
//  TrackingApp
//
//  Created by Jose on 23/10/2024.
//
//  Purpose: Generic loading state enumeration
//  Details: Defines possible states for data loading operations
//

import Foundation

enum LoadingState<T: Equatable>: Equatable {
    static func == (lhs: LoadingState<T>, rhs: LoadingState<T>) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.loaded(let lhsValue), .loaded(let rhsValue)):
            return lhsValue == rhsValue
        case (.empty, .empty):
            return true
        case (.error(let lhsError), .error(let rhsError)):
            // Compare errors if they are the same instance or have the same description.
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
    
    case loading
    case loaded(T)
    case empty
    case error(Error)
}
