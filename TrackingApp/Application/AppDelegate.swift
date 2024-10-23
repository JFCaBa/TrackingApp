//
//  AppDelegate.swift
//  TrackingApp
//
//  Created by Jose on 23/10/2024.
//

import UIKit
import CoreData

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    private var appCoordinator: AppCoordinator?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        TransportationModeDetectionService.shared.startMonitoring()
        
        setupWindow()
        setupAppCoordinator()
        
        return true
    }
    
    private func setupWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .systemBackground
    }
    
    private func setupAppCoordinator() {
        guard let window = window else { return }
        appCoordinator = AppCoordinator(window: window)
        appCoordinator?.start()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackingApp")
        container.loadPersistentStores { [weak self] (storeDescription, error) in
            if let error = error as NSError? {
                self?.handlePersistentStoreError(error)
            }
        }
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext() {
        let context = persistentContainer.viewContext
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            handleContextSaveError(error)
        }
    }
    
    // MARK: - Error Handling
    
    private func handlePersistentStoreError(_ error: NSError) {
        #if DEBUG
        fatalError("Persistent store error: \(error), \(error.userInfo)")
        #else
        // In production, log the error and show user-friendly message
        print("Persistent store error: \(error), \(error.userInfo)")
        // TODO: Implement proper error handling for production
        #endif
    }
    
    private func handleContextSaveError(_ error: Error) {
        #if DEBUG
        let nsError = error as NSError
        fatalError("Context save error: \(nsError), \(nsError.userInfo)")
        #else
        // In production, log the error and show user-friendly message
        print("Context save error: \(error.localizedDescription)")
        // TODO: Implement proper error handling for production
        #endif
    }
}
