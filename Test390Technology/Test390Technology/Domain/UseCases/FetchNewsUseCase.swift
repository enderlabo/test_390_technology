//
//  FetchNewsUseCase.swift
//  Test390Technology
//
//  Created by Elderson Laborit on 4/14/25.
//

import Foundation
import Combine

final class FetchNewsUseCase: FetchNewsUseCaseProtocol {
    private let newsRepository: NewsRepositoryProtocol
    private let favoritesService: FavoritesServiceProtocol
    
    init(newsRepository: NewsRepositoryProtocol,
         favoritesService: FavoritesServiceProtocol) {
        self.newsRepository = newsRepository
        self.favoritesService = favoritesService
    }
    
    func execute(forceRefresh: Bool = false) -> AnyPublisher<[NewsArticle], APIError> {
        newsRepository.fetchNews(forceRefresh: forceRefresh)
            .flatMap { [weak self] articles -> AnyPublisher<[NewsArticle], APIError> in
                guard let self = self else {
                    return Fail(error: APIError.unknown).eraseToAnyPublisher()
                }
                return self.enrichWithFavorites(articles: articles)
            }
            .eraseToAnyPublisher()
    }
    
    private func enrichWithFavorites(articles: [NewsArticle]) -> AnyPublisher<[NewsArticle], APIError> {
        let articleIds = articles.compactMap { $0.id }
        
        return favoritesService.getFavoritesStatus(for: articleIds)
            .map { favoriteStatuses in
                articles.map { article in
                    var modified = article
                    modified.isFavorite = favoriteStatuses[article.id ?? ""] ?? false
                    return modified
                }
            }
            .mapError { _ in APIError.persistenceError(description: "Failed to fetch favorite status") }
            .eraseToAnyPublisher()
    }
}
