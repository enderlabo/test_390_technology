//
//  NewItemsModel.swift
//  Test390Technology
//
//  Created by Elderson Laborit on 4/14/25.
//

import Foundation

struct NewsArticle: Identifiable, Hashable, Codable {
    let id: String?
    let source: NewsSource
    let author: String?
    let title: String
    let description: String?
    let url: URL
    let urlToImage: URL?
    let publishedAt: String
    let content: String?
    var isFavorite: Bool
    
    init(
        id: String? = nil,
        source: NewsSource,
        author: String?,
        title: String,
        description: String?,
        url: URL,
        urlToImage: URL?,
        publishedAt: String,
        content: String?,
        isFavorite: Bool = false
    ) {
        self.id = id ?? Self.generateID(from: url)
        self.source = source
        self.author = author
        self.title = title
        self.description = description
        self.url = url
        self.urlToImage = urlToImage
        self.publishedAt = publishedAt
        self.content = content
        self.isFavorite = isFavorite
    }
    
    static func generateID(from url: URL) -> String {
        url.absoluteString.stableHash()
    }
}

struct NewsSource: Identifiable, Hashable, Codable {
    let id: String?
    let name: String
    
    var stableId: String {
        id ?? name.stableHash()
    }
}

