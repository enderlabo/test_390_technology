//
//  DIContainer.swift
//  Test390Technology
//
//  Created by Elderson Laborit on 4/14/25.
//

import Foundation
import UIKit
import Combine
import CoreData

final class DIContainer {
    
    // MARK: - Singleton
    static let shared = DIContainer()
    
    // MARK: - UI Components
    lazy var uiComponents: UIComponents = {
        return UIComponents(container: self)
    }()
    
    class UIComponents {
        private weak var container: DIContainer?
        
        init(container: DIContainer) {
            self.container = container
        }
        
//       func configureNewsCell(_ cell: NewsCell, with article: NewsArticle) {
//           cell.configure(with: article ) { [weak container] article in
//               container?.newsRepository.toggleFavorite(article: article)
//                   .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
//                   .store(in: &cell.cancellables)
//           }
//       }
   }
       
       private init() {
           // Constructor privado para el Singleton
       }
        // MARK: - Core Data
        private lazy var coreDataManager: CoreDataManagerProtocol = CoreDataManager.shared
        
        // MARK: - Cache
        private lazy var memoryCache: MemoryCacheProtocol = MemoryCache.shared
        
        private lazy var cachedDataSource: CachedDataSourceProtocol = {
            CachedDataSource(
                coreDataManager: coreDataManager,
                favoritesDataSource: favoritesDataSource
            )
        }()
        
        // MARK: - Data Sources
        private lazy var favoritesDataSource: FavoritesDataSourceProtocol = {
            FavoritesDataSource(coreDataManager: coreDataManager)
        }()
        
        private lazy var apiClient: APIClientProtocol = {
            APIClient()
        }()
        
        // MARK: - Services
        private lazy var favoritesService: FavoritesServiceProtocol = {
            FavoritesService(dataSource: favoritesDataSource)
        }()
        
        // MARK: - Repositories
        private lazy var newsRepository: NewsRepositoryProtocol = {
            do {
                let apiKey = try KeychainHandler.shared.get(
                            service: "com.tuapp.newsapi",
                            account: "apiKey"
                        )
                return NewsRepository(
                            apiClient: apiClient,
                            memoryCache: memoryCache,
                            cachedDataSource: cachedDataSource,
                            apiKey: apiKey,
                            favoritesDataSource: favoritesDataSource)
            } catch{
                fatalError("can't get apiKey from keychain: \(error)")
            }
        }()
        
        private lazy var favoritesRepository: FavoritesRepositoryProtocol = {
            FavoritesRepository(dataSource: favoritesDataSource)
        }()
        
        // MARK: - Use Cases
        func makeFetchNewsUseCase() -> FetchNewsUseCaseProtocol {
            FetchNewsUseCase(
                newsRepository: newsRepository,
                favoritesService: favoritesService
            )
        }
        
        func makeToggleFavoriteUseCase() -> ToggleFavoriteUseCaseProtocol {
            ToggleFavoriteUseCase(repository: favoritesRepository)
        }
        
        // MARK: - ViewModels
        func makeNewsViewModel() -> NewsViewModel {
            NewsViewModel(repository: newsRepository)
        }
        
        // MARK: - ViewControllers
        func makeNewsViewController() -> UIViewController {
            let viewModel = NewsViewModel(repository: newsRepository)
            let viewController = NewsViewController(viewModel: viewModel)
            viewModel.coordinatorDelegate = viewController.viewModel.coordinatorDelegate
            return viewController
        }
        
        func  makeArticleDetailViewController(article: NewsArticle) -> ArticleDetailViewController {
            ArticleDetailViewController(article: article)
        }
        
        // MARK: - Coordinators
        func makeAppCoordinator(window: UIWindow) -> AppCoordinator {
            AppCoordinator(
                window: window,
                diContainer: DIContainer()
            )
        }
        
        func makeHomeCoordinator(navigationController: UINavigationController) -> NewsCoordinator {
            NewsCoordinator(
                navigationController: navigationController,
                diContainer: DIContainer()
            )
        }
        
        func makeRootNavigationController() -> UINavigationController {
            let navigationController = UINavigationController()
            navigationController.navigationBar.prefersLargeTitles = true
            return navigationController
        }
        
        
    }
    
