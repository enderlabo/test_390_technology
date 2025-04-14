//
//  NewsRepository.swift
//  Test390Technology
//
//  Created by Elderson Laborit on 4/14/25.
//

import Foundation
import Combine

final class FavoritesRepository: FavoritesRepositoryProtocol {
    
    private let dataSource: FavoritesDataSourceProtocol
    
    init(dataSource: FavoritesDataSourceProtocol) {
        self.dataSource = dataSource
    }
    
    func toggleFavorite(article: NewsArticle) -> AnyPublisher<NewsArticle, Error> {
        dataSource.toggleFavorite(article: article)
    }
    
    func isFavorite(articleId: String) -> AnyPublisher<Bool, Error> {
        dataSource.isFavorite(articleId: articleId)
    }
    
    func fetchFavorites() -> AnyPublisher<[NewsArticle], Error> {
        dataSource.fetchFavorites()
    }
}

final class CachedRepository: CachedRepositoryProtocol {
    private let dataSource: CachedDataSourceProtocol
    
    init(dataSource: CachedDataSourceProtocol) {
        self.dataSource = dataSource
    }
    
    func cacheArticles(_ articles: [NewsArticle]) -> AnyPublisher<Void, Error> {
        dataSource.cacheArticles(articles)
    }
    
    func fetchCachedArticles() -> AnyPublisher<[NewsArticle], Error> {
        dataSource.fetchCachedArticles()
    }
}
