//
//  ToggleFavoriteUseCaseProtocol.swift
//  Test390Technology
//
//  Created by Elderson Laborit on 4/14/25.
//

import Foundation
import Combine

protocol ToggleFavoriteUseCaseProtocol {
    func execute(article: NewsArticle) -> AnyPublisher<NewsArticle, APIError>
}
