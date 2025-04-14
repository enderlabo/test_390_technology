//
//  NewsCellViewModel.swift
//  Test390Technology
//
//  Created by Elderson Laborit on 4/14/25.
//

import Foundation
import Combine

final class NewsCellViewModel: NewsCellViewModelProtocol {
    private let article: NewsArticle
    private let favoriteToggleSubject = PassthroughSubject<Bool, Never>()
    
    init(article: NewsArticle) {
        self.article = article
    }
    
    var title: String {
        return article.title
    }
    
    var author: String {
        return article.author ?? APIError.unknown.localizedDescription
    }
    
    var imageURL: URL? {
        return article.urlToImage
    }
    
    var isFavorite: Bool {
        return article.isFavorite
    }
    
    var onFavoriteToggle: AnyPublisher<Bool, Never> {
        return favoriteToggleSubject.eraseToAnyPublisher()
    }
    
    func toggleFavorite() {
        favoriteToggleSubject.send(!article.isFavorite)
    }
}
