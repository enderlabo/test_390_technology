//
//  FetchCachedArticlesUseCase.swift
//  Test390Technology
//
//  Created by Elderson Laborit on 4/14/25.
//

import Foundation
import Combine

struct FetchCachedArticlesUseCase {
    private let repository: CachedRepositoryProtocol
    
    init(repository: CachedRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() -> AnyPublisher<[NewsArticle], Error> {
        repository.fetchCachedArticles()
    }
}
