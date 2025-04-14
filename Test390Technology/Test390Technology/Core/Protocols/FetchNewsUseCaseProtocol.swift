//
//  FetchNewsUseCaseProtocol.swift
//  Test390Technology
//
//  Created by Elderson Laborit on 4/14/25.
//

import Foundation
import Combine

protocol FetchNewsUseCaseProtocol {
    func execute(forceRefresh: Bool) -> AnyPublisher<[NewsArticle], APIError>
}
