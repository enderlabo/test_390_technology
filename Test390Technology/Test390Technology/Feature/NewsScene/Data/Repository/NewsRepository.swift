//
//  NewsRepository.swift
//  Test390Technology
//
//  Created by Elderson Laborit on 4/14/25.
//

import Foundation
import Combine
import CoreData

final class NewsRepository: NewsRepositoryProtocol {
    
    private let apiClient: APIClientProtocol
    private let memoryCache: MemoryCacheProtocol
    private let cachedDataSource: CachedDataSourceProtocol
    private let apiKey: String
    private let favoritesDataSource: FavoritesDataSourceProtocol
    
    init(
        apiClient: APIClientProtocol,
        memoryCache: MemoryCacheProtocol,
        cachedDataSource: CachedDataSourceProtocol,
        apiKey: String,
        favoritesDataSource: FavoritesDataSourceProtocol
    ) {
        self.apiClient = apiClient
        self.memoryCache = memoryCache
        self.cachedDataSource = cachedDataSource
        self.apiKey = apiKey
        self.favoritesDataSource = favoritesDataSource
    }
    
    func fetchNews() -> AnyPublisher<[NewsArticle], APIError> {
        let cacheKey = "news_articles"
        
        return memoryCache.getNewsArticles(forKey: cacheKey)
            .mapError { _ in APIError.cacheError }
            .flatMap { [weak self] cachedArticles -> AnyPublisher<[NewsArticle], APIError> in
                
                if let articles = cachedArticles, !articles.isEmpty {
                    return self?.updateFavoritesStatus(articles: articles)
                        .mapError { error in APIError.persistenceError(description: error.localizedDescription) }
                        .flatMap { updatedArticles -> AnyPublisher<[NewsArticle], APIError> in
                            
                            return self?.memoryCache.cache(updatedArticles, forKey: cacheKey, expiration: 300)
                                .mapError { _ in APIError.cacheError }
                                .map { _ in updatedArticles }
                                .eraseToAnyPublisher()
                                ?? Fail(error: APIError.unknown).eraseToAnyPublisher()
                        }
                        .eraseToAnyPublisher()
                        ?? Fail(error: APIError.unknown).eraseToAnyPublisher()
                }
                
                return self?.cachedDataSource.fetchCachedArticles()
                   .mapError { error in APIError.persistenceError(description: error.localizedDescription) }
                   .flatMap { articles -> AnyPublisher<[NewsArticle], APIError> in
                       if !articles.isEmpty {
                           return self?.updateFavoritesStatus(articles: articles)
                              .mapError { error in APIError.persistenceError(description: error.localizedDescription) }
                              .flatMap { updatedArticles -> AnyPublisher<[NewsArticle], APIError> in
                                  return self?.memoryCache.cache(updatedArticles, forKey: cacheKey, expiration: 300)
                                      .mapError { _ in APIError.cacheError }
                                      .map { _ in updatedArticles }
                                      .eraseToAnyPublisher()
                                      ?? Fail(error: APIError.unknown).eraseToAnyPublisher()
                              }
                              .eraseToAnyPublisher()
                              ?? Fail(error: APIError.unknown).eraseToAnyPublisher()
                       }
                       
                       return self?.fetchFromAPI(cacheKey: cacheKey)
                           ?? Fail(error: APIError.unknown).eraseToAnyPublisher()
                   }
                   .eraseToAnyPublisher()
                   ?? Fail(error: APIError.unknown).eraseToAnyPublisher()
           }
           .eraseToAnyPublisher()
    }
    
    private func updateFavoritesStatus(articles: [NewsArticle]) -> AnyPublisher<[NewsArticle], Error> {
        let articleIds = articles.compactMap { $0.id }
        
        return favoritesDataSource.getFavoritesStatus(for: articleIds)
            .map { favoriteStatus -> [NewsArticle] in
                return articles.map { article in
                    var updatedArticle = article
                    if let id = article.id, let isFavorite = favoriteStatus[id] {
                        updatedArticle.isFavorite = isFavorite
                    }
                    return updatedArticle
                }
            }
            .eraseToAnyPublisher()
        }
    
    private func fetchFromAPI(cacheKey: String) -> AnyPublisher<[NewsArticle], APIError> {
        let apiKey = APIKeyManager.shared.getAPIKey()
        let endpoint = Endpoint.everything(query: "sport", apiKey: apiKey)
        
        return apiClient.request(endpoint: endpoint)
            .mapError { error -> APIError in
                if let apiError = error as? APIError {
                    return apiError
                }
                return APIError.network(description: error.localizedDescription)
            }
            .map { (response: NewsAPIResponse) in
                response.articles.compactMap { $0.toDomain() }
            }
            .flatMap { [weak self] articles -> AnyPublisher<[NewsArticle], APIError> in
                guard let self = self else {
                    return Fail(error: APIError.unknown).eraseToAnyPublisher()
                }
                
                return self.updateFavoritesStatus(articles: articles)
                   .mapError { error in APIError.persistenceError(description: error.localizedDescription) }
                   .flatMap { updatedArticles -> AnyPublisher<[NewsArticle], APIError> in
                       let saveToMemory = self.memoryCache.cache(updatedArticles, forKey: cacheKey, expiration: 300)
                           .mapError { error in APIError.cacheError }
                       
                       let saveToDisk = self.cachedDataSource.cacheArticles(updatedArticles)
                           .mapError { error in APIError.persistenceError(description: error.localizedDescription) }
                       
                       return saveToMemory
                           .zip(saveToDisk)
                           .map { _ in updatedArticles }
                           .eraseToAnyPublisher()
                   }
                   .eraseToAnyPublisher()
           }
           .eraseToAnyPublisher()
    }
    
    func fetchNews(forceRefresh: Bool) -> AnyPublisher<[NewsArticle], APIError> {
            let cacheKey = "news_articles"
            
            if forceRefresh {
                print("DEBUG: - Pull Refresh")
                return fetchFromAPI(cacheKey: cacheKey)
            }
            
            return fetchNews()
        }
        
    func toggleFavorite(article: NewsArticle) -> AnyPublisher<NewsArticle, APIError> {
        return favoritesDataSource.toggleFavorite(article: article)
            .mapError { error in
                APIError.persistenceError(description: error.localizedDescription)
            }
            .flatMap { [weak self] updatedArticle -> AnyPublisher<NewsArticle, APIError> in
                guard let self = self else {
                    return Just(updatedArticle).setFailureType(to: APIError.self).eraseToAnyPublisher()
                }
                
                let cacheKey = "news_articles"
                return self.memoryCache.getNewsArticles(forKey: cacheKey)
                    .mapError { _ in APIError.cacheError }
                    .flatMap { cachedArticles -> AnyPublisher<NewsArticle, APIError> in
                        if var articles = cachedArticles {
                            if let index = articles.firstIndex(where: { $0.id == updatedArticle.id }) {
                                articles[index] = updatedArticle
                                
                                return self.memoryCache.cache(articles, forKey: cacheKey, expiration: 300)
                                    .mapError { _ in APIError.cacheError }
                                    .map { _ in updatedArticle }
                                    .eraseToAnyPublisher()
                            }
                        }
                        
                        return Just(updatedArticle).setFailureType(to: APIError.self).eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        }
    
}

extension MemoryCacheProtocol {
    func getNewsArticles(forKey key: String) -> AnyPublisher<[NewsArticle]?, Error> {
        return self.get(forKey: key)
    }
}
