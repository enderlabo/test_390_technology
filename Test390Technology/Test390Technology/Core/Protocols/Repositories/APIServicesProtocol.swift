//
//  APIServicesProtocol.swift
//  Test390Technology
//
//  Created by Elderson Laborit on 4/14/25.
//

import Foundation
import Combine

protocol APIServiceProtocol {
    func fetchSportArticles(forceRefresh: Bool) -> AnyPublisher<[NewsArticle], Error>
}
