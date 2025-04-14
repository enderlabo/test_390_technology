//
//  FavoritesRepositoryProtocol.swift
//  Test390Technology
//
//  Created by Elderson Laborit on 4/14/25.
//

import Foundation
import Combine

protocol FavoritesRepositoryProtocol {
    func toggleFavorite(article: NewsArticle) -> AnyPublisher<NewsArticle, Error>
    func isFavorite(articleId: String) -> AnyPublisher<Bool, Error>
    func fetchFavorites() -> AnyPublisher<[NewsArticle], Error>
}
