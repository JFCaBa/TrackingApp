import UIKit

final class AppCoordinator: Coordinator {
    private let window: UIWindow
    private var childCoordinators: [Coordinator] = []
    private let tabBarController: UITabBarController
    
    init(window: UIWindow) {
        self.window = window
        self.tabBarController = UITabBarController()
    }
    
    func start() {
        setupTabBarAppearance()
        setupViewControllers()
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = .secondarySystemGroupedBackground
        
        // Configure unselected state
        appearance.stackedLayoutAppearance.normal.iconColor = .label
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.label
        ]
        
        // Configure selected state
        appearance.stackedLayoutAppearance.selected.iconColor = .systemBlue
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.systemBlue
        ]
        
        tabBarController.tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBarController.tabBar.scrollEdgeAppearance = appearance
        }
        
        // Set the tint color for the selected items
        tabBarController.tabBar.tintColor = .systemBlue
        
        // Set the unselected tint color
        tabBarController.tabBar.unselectedItemTintColor = .white
    }
    
    private func setupViewControllers() {
        let mapCoordinator = MapCoordinator()
        let tripsCoordinator = TripsCoordinator()
        let statisticsCoordinator = StatisticsCoordinator()
        
        childCoordinators = [mapCoordinator, tripsCoordinator, statisticsCoordinator]
        
        let mapViewController = mapCoordinator.createViewController()
        let tripsViewController = tripsCoordinator.createViewController()
        let statisticsViewController = statisticsCoordinator.createViewController()
        
        // Configure Map Tab
        mapViewController.tabBarItem = UITabBarItem(
            title: "Map",
            image: UIImage(systemName: "map")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(systemName: "map.fill")?.withRenderingMode(.alwaysTemplate)
        )
        
        // Configure Trips Tab
        tripsViewController.tabBarItem = UITabBarItem(
            title: "Trips",
            image: UIImage(systemName: "list.bullet")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(systemName: "list.bullet.fill")?.withRenderingMode(.alwaysTemplate)
        )
        
        // Configure Statistics Tab
        statisticsViewController.tabBarItem = UITabBarItem(
            title: "Statistics",
            image: UIImage(systemName: "chart.bar")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(systemName: "chart.bar.fill")?.withRenderingMode(.alwaysTemplate)
        )
        
        let viewControllers = [
            mapViewController,
            tripsViewController,
            statisticsViewController
        ]
        
        tabBarController.setViewControllers(viewControllers, animated: false)
        tabBarController.selectedIndex = 0
    }
}

// MARK: - Coordinator Protocol
protocol Coordinator: AnyObject {
    func start()
}

// MARK: - Notification Extension
extension Notification.Name {
    static let locationDidUpdate = Notification.Name("locationDidUpdate")
}
