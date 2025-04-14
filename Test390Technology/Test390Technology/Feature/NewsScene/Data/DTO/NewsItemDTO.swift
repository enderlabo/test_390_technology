//
//  NewsItemDTO.swift
//  Test390Technology
//
//  Created by Elderson Laborit on 4/14/25.
//

import Foundation

struct NewsAPIResponse: Decodable {
    let articles: [NewsArticleDTO]
}

struct NewsArticleDTO: Decodable {
    let source: NewsSourceDTO
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
    let content: String?
    
    struct NewsSourceDTO: Decodable {
        let id: String?
        let name: String
    }
    
    func toDomain() -> NewsArticle? {
        guard let url = URL(string: url) else {
            debugPrint("Invalid URL: \(url)")
            return nil
        }
        
        let dateFormatter = ISO8601DateFormatter()
        guard let date = dateFormatter.date(from: publishedAt) else {
            debugPrint("Invalid date format: \(publishedAt)")
            return nil
        }
        
        return NewsArticle(
            source: NewsSource(
                id: source.id,
                name: source.name
            ),
            author: author,
            title: title,
            description: description,
            url: url,
            urlToImage: urlToImage.flatMap(URL.init),
            publishedAt: date.description,
            content: content?.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
}
