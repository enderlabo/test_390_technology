    //
    //  FavoritesLocalDataSourceImpl.swift
    //  Test390Technology
    //
    //  Created by Elderson Laborit on 4/14/25.
    //

    import Foundation
    import CoreData
    import Combine

    protocol FavoritesServiceProtocol {
        func isFavorite(articleId: String) -> AnyPublisher<Bool, Error>
        func toggleFavorite(article: NewsArticle) -> AnyPublisher<NewsArticle, Error>
        func getFavoritesStatus(for articleIds: [String]) -> AnyPublisher<[String: Bool], Error>
    }

    final class FavoritesService: FavoritesServiceProtocol {
        func getFavoritesStatus(for articleIds: [String]) -> AnyPublisher<[String: Bool], Error> {
            dataSource.getFavoritesStatus(for: articleIds)
        }
        
        private let dataSource: FavoritesDataSourceProtocol
            
        init(dataSource: FavoritesDataSourceProtocol) {
            self.dataSource = dataSource
        }
        
        func isFavorite(articleId: String) -> AnyPublisher<Bool, Error> {
                dataSource.isFavorite(articleId: articleId)
            }
        
        func toggleFavorite(article: NewsArticle) -> AnyPublisher<NewsArticle, Error> {
            guard article.id != nil else {
                return Fail(error: NSError(domain: "FavoritesService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Article ID is missing"])).eraseToAnyPublisher()
            }
            
            return dataSource.toggleFavorite(article: article)
                .map { updatedArticle in
                    return updatedArticle
                }
                .eraseToAnyPublisher()
        }
    }
