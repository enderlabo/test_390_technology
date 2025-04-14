//
//  CachedRepositoryProtocol.swift
//  Test390Technology
//
//  Created by Elderson Laborit on 4/14/25.
//

import Foundation
import Combine

protocol CachedRepositoryProtocol {
    func cacheArticles(_ articles: [NewsArticle]) -> AnyPublisher<Void, Error>
    func fetchCachedArticles() -> AnyPublisher<[NewsArticle], Error>
}
