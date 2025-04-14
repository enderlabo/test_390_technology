//
//  CacheArticlesUseCase.swift
//  Test390Technology
//
//  Created by Elderson Laborit on 4/14/25.
//

import Foundation
import Combine

struct CacheArticlesUseCase {
    private let repository: CachedRepositoryProtocol
    
    init(repository: CachedRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(articles: [NewsArticle]) -> AnyPublisher<Void, Error> {
        repository.cacheArticles(articles)
    }
}
