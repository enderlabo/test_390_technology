//
//  newItemsDTO.swift
//  Test390Technology
//
//  Created by Elderson Laborit on 4/14/25.
//

import Foundation

struct NewsResponseDTO: Decodable {
    let articles: [NewsArticleDTO]
    
    func toDomain() -> [NewsArticle] {
        articles.compactMap { $0.toDomain() }
    }
}
