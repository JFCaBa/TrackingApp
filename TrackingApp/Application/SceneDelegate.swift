//
//  SceneDelegate.swift
//  TrackingApp
//
//  Created by Jose on 23/10/2024.
//
//  Purpose: Scene lifecycle management for multi-window support
//  Details: Handles scene-specific lifecycle events and window setup
//

import UIKit
import Combine

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    private var appCoordinator: AppCoordinator?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Scene Lifecycle
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        setupWindow(with: windowScene)
        setupAppCoordinator()
        handleConnectionOptions(connectionOptions)
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        cleanup()
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        resumeTracking()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        pauseTracking()
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        prepareForegroundTasks()
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        saveApplicationState()
    }
    
    // MARK: - Private Setup Methods
    
    private func setupWindow(with windowScene: UIWindowScene) {
        window = UIWindow(windowScene: windowScene)
        window?.backgroundColor = .systemBackground
    }
    
    private func setupAppCoordinator() {
        guard let window = window else { return }
        appCoordinator = AppCoordinator(window: window)
        appCoordinator?.start()
    }
    
    private func handleConnectionOptions(_ options: UIScene.ConnectionOptions) {
        // Handle any deep links or shortcuts here
        if let urlContext = options.urlContexts.first {
            handleDeepLink(urlContext.url)
        }
    }
    
    // MARK: - State Management
    
    private func resumeTracking() {
        AppLocationManager.shared.startUpdatingLocation()
    }
    
    private func pauseTracking() {
        // Implement any pause behavior if needed
    }
    
    private func prepareForegroundTasks() {
        // Refresh data or prepare UI
    }
    
    private func saveApplicationState() {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    private func cleanup() {
        cancellables.removeAll()
    }
    
    // MARK: - Deep Linking
    
    private func handleDeepLink(_ url: URL) {
        // Implement deep linking navigation
        print("Handling deep link: \(url)")
    }
}

// MARK: - Error Handling

extension SceneDelegate {
    private func handleError(_ error: Error) {
        #if DEBUG
        print("SceneDelegate error: \(error.localizedDescription)")
        #else
        // Implement production error handling
        #endif
    }
}
