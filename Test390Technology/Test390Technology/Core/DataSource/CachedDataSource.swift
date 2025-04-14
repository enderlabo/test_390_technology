//
//  CachedDataSource.swift
//  Test390Technology
//
//  Created by Elderson Laborit on 4/14/25.
//

import Foundation
import Combine
import CoreData

protocol CachedDataSourceProtocol {
    func cacheArticles(_ articles: [NewsArticle]) -> AnyPublisher<Void, Error>
    func fetchCachedArticles() -> AnyPublisher<[NewsArticle], Error>
}

final class CachedDataSource: CachedDataSourceProtocol {
    private let coreDataManager: CoreDataManagerProtocol
    private let favoritesDataSource: FavoritesDataSourceProtocol
    
    init(coreDataManager: CoreDataManagerProtocol = CoreDataManager.shared,
         favoritesDataSource: FavoritesDataSourceProtocol) {
        self.coreDataManager = coreDataManager
        self.favoritesDataSource = favoritesDataSource
    }
    
    func cacheArticles(_ articles: [NewsArticle]) -> AnyPublisher<Void, Error> {
        let articleIds = articles.compactMap { $0.id }
        
        return favoritesDataSource.getFavoritesStatus(for: articleIds)
            .flatMap { [weak self] favoriteStatus -> AnyPublisher<Void, Error> in
                guard let self = self else {
                    return Fail(error: NSError(domain: "CachedDataSource", code: -1, userInfo: nil)).eraseToAnyPublisher()
                }
                
                return Future { promise in
                    self.coreDataManager.performBackgroundTask { context in
                        let deleteRequest = NSBatchDeleteRequest(fetchRequest: CachedArticle.fetchRequest())
                        
                        do {
                            try context.execute(deleteRequest)
                            
                            for article in articles {
                                let cached = CachedArticle(context: context)
                                cached.id = article.id ?? NewsArticle.generateID(from: article.url)
                                cached.title = article.title
                                cached.articleDescription = article.description
                                cached.url = article.url
                                cached.urlToImage = article.urlToImage?.absoluteString
                                cached.publishedAt = article.publishedAt
                                cached.content = article.content
                                cached.sourceName = article.source.name
                                cached.author = article.author
                                cached.savedAt = Date().ISO8601Format()
                                
                                if let id = article.id, let isFavorite = favoriteStatus[id] {
                                    cached.isFavorite = isFavorite
                                } else {
                                    cached.isFavorite = article.isFavorite
                                }
                            }
                            
                            try context.save()
                            promise(.success(()))
                        } catch {
                            promise(.failure(error))
                        }
                    }
                }.eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func fetchCachedArticles() -> AnyPublisher<[NewsArticle], Error> {
        Future { [weak self] promise in
            self?.coreDataManager.performBackgroundTask { context in
                let request: NSFetchRequest<CachedArticle> = CachedArticle.fetchRequest()
                request.sortDescriptors = [NSSortDescriptor(key: "savedAt", ascending: false)]
                
                do {
                    let cached = try context.fetch(request)
                    let articles = cached.compactMap { self?.convertToNewsArticle(cached: $0) }
                    promise(.success(articles))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func convertToNewsArticle(cached: CachedArticle) -> NewsArticle? {
        guard let id = cached.id,
              let title = cached.title,
              let urlString = cached.url,
              let url = URL(string: urlString.absoluteString),
              let publishedAtString = cached.publishedAt,
              let publishedAt = ISO8601DateFormatter().date(from: publishedAtString) else {
            return nil
        }
        
        return NewsArticle(
            id: id,
            source: NewsSource(
                id: nil,
                name: cached.sourceName ?? "Unknown"
            ),
            author: cached.author,
            title: title,
            description: cached.articleDescription,
            url: url,
            urlToImage: cached.urlToImage.flatMap(URL.init),
            publishedAt: publishedAt.description,
            content: cached.content,
            isFavorite: cached.isFavorite
        )
    }
}
