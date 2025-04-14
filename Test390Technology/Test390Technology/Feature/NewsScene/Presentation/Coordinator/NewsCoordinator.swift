//
//  NewsCoordinator.swift
//  Test390Technology
//
//  Created by Elderson Laborit on 4/12/25.
//

import Foundation
import UIKit

final class NewsCoordinator: Coordinator {
    var childCoordinators: [any Coordinator] = []
    var navigationController: UINavigationController
    private let diContainer: DIContainer
    
    init(navigationController: UINavigationController, diContainer: DIContainer) {
        self.navigationController = navigationController
        self.diContainer = diContainer
    }
    
    func start() {
        let viewController = diContainer.makeNewsViewController()
            
        if let viewModel = (viewController as? NewsViewController)?.viewModel {
            viewModel.coordinatorDelegate = self
        }

        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showArticleDetail(_ article: NewsArticle) {
         let detailVC = diContainer.makeArticleDetailViewController(article: article)
         navigationController.pushViewController(detailVC, animated: true)
    }
}
