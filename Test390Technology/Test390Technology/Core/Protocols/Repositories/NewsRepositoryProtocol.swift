//
//  NewsRepositoryProtocol.swift
//  Test390Technology
//
//  Created by Elderson Laborit on 4/14/25.
//

import Foundation
import Combine

protocol NewsRepositoryProtocol {
    func fetchNews(forceRefresh: Bool) -> AnyPublisher<[NewsArticle], APIError>
    func toggleFavorite(article: NewsArticle) -> AnyPublisher<NewsArticle, APIError>
}


