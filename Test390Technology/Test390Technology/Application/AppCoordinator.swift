//
//  AppCoordinator.swift
//  Test390Technology
//
//  Created by Elderson Laborit on 4/14/25.
//

import UIKit

final class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    private let window: UIWindow
    private let diContainer: DIContainer
    
    init(window: UIWindow, diContainer: DIContainer) {
        self.window = window
        self.diContainer = diContainer
        self.navigationController = UINavigationController()
    }
    
    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        let homeCoordinator = NewsCoordinator(
            navigationController: navigationController,
            diContainer: diContainer
        )
        addChildCoordinator(homeCoordinator)
        homeCoordinator.start()
    }
}
