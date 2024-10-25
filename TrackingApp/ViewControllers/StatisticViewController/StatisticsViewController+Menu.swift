//
//  StatisticsViewController+Menu.swift
//  TrackingApp
//
//  Created by Jose on 25/10/2024.
//

import UIKit

extension StatisticsViewController {
    func setupNavigationMenu() {
        let menu = UIMenu(title: "", options: .displayInline, children: [
            UIAction(
                title: "Reset All Data",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { [weak self] _ in
                self?.showResetConfirmation()
            }
        ])
        
        let menuButton = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis.circle"),
            menu: menu
        )
        
        navigationItem.rightBarButtonItem = menuButton
    }
    
    private func showResetConfirmation() {
        let alert = UIAlertController(
            title: "Reset All Data",
            message: "This will permanently delete all your trips. This action cannot be undone.",
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { [weak self] _ in
            self?.resetAllData()
        })
        
        present(alert, animated: true)
    }
    
    private func resetAllData() {
        CoreDataManager.shared.deleteAllTrips()
        viewModel.loadStatistics()
    }
}
