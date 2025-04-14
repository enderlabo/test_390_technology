//
//  ToggleFavoriteUseCase.swift
//  Test390Technology
//
//  Created by Elderson Laborit on 4/14/25.
//

import Foundation
import Combine

struct ToggleFavoriteUseCase: ToggleFavoriteUseCaseProtocol {
    private let repository: FavoritesRepositoryProtocol
    
    init(repository: FavoritesRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(article: NewsArticle) -> AnyPublisher<NewsArticle, APIError> {
        repository.toggleFavorite(article: article)
            .handleEvents(receiveOutput: { updatedArticle in
                print("Favorite toggled. New article state: \(updatedArticle.isFavorite)")
            })
            .mapError { _ in APIError.persistenceError(description: "Failed to toggle favorite status") }
            .eraseToAnyPublisher()
    }
}
