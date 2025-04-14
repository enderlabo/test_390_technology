//
//  FavoritesDataSource.swift
//  Test390Technology
//
//  Created by Elderson Laborit on 4/14/25.
//

import Foundation
import CoreData
import Combine

protocol FavoritesDataSourceProtocol {
    func isFavorite(articleId: String) -> AnyPublisher<Bool, Error>
    func toggleFavorite(article: NewsArticle) -> AnyPublisher<NewsArticle, Error>
    func fetchFavorites() -> AnyPublisher<[NewsArticle], Error>
    func generateArticleID(for article: NewsArticle) -> String
    func getFavoritesStatus(for articleIds: [String]) -> AnyPublisher<[String: Bool], Error>
    
}

final class FavoritesDataSource: FavoritesDataSourceProtocol {
    private let coreDataManager: CoreDataManagerProtocol
    
    init(coreDataManager: CoreDataManagerProtocol = CoreDataManager.shared) {
        self.coreDataManager = coreDataManager
    }
    
    func isFavorite(articleId: String) -> AnyPublisher<Bool, Error> {
        Future { [weak self] promise in
            self?.coreDataManager.performBackgroundTask { context in
                let request: NSFetchRequest<FavoriteArticle> = FavoriteArticle.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", articleId)
                request.fetchLimit = 1
                
                do {
                    let count = try context.count(for: request)
                    promise(.success(count > 0))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func toggleFavorite(article: NewsArticle) -> AnyPublisher<NewsArticle, Error> {
        guard let articleId = article.id else {
            return Fail(error: FavoritesError.invalidID).eraseToAnyPublisher()
        }
        
        return Future { [weak self] promise in
            self?.coreDataManager.performBackgroundTask { context in
                let request: NSFetchRequest<FavoriteArticle> = FavoriteArticle.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", articleId)
                request.fetchLimit = 1
                
                do {
                    if let existing = try context.fetch(request).first {
                        context.delete(existing)
                        try context.save()
                        
                        var updatedArticle = article
                        updatedArticle.isFavorite = false
                        promise(.success(updatedArticle))
                    } else {
                        let favorite = FavoriteArticle(context: context)
                        favorite.id = articleId
                        favorite.title = article.title
                        favorite.articleDescription = article.description
                        favorite.url = article.url
                        favorite.urlToImage = article.urlToImage?.absoluteString
                        favorite.publishedAt = article.publishedAt
                        favorite.content = article.content
                        favorite.sourceName = article.sourceName
                        favorite.author = article.author
                        favorite.favoritedAt = Date()
                        
                        try context.save()
                        
                        var updatedArticle = article
                        updatedArticle.isFavorite = true
                        promise(.success(updatedArticle))
                    }
                } catch {
                    promise(.failure(FavoritesError.coreDataError(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func generateArticleID(for article: NewsArticle) -> String {
        return article.id ?? UUID().uuidString
    }

    private func createFavoriteEntity(from article: NewsArticle,
                                    id: String,
                                    context: NSManagedObjectContext) -> FavoriteArticle {
        let favorite = FavoriteArticle(context: context)
        favorite.id = id
        favorite.title = article.title
        favorite.articleDescription = article.description
        favorite.url = article.url
        favorite.urlToImage = article.urlToImage?.absoluteString
        favorite.publishedAt = article.publishedAt
        favorite.content = article.content
        favorite.sourceName = article.sourceName
        favorite.author = article.author
        favorite.favoritedAt = Date()
        return favorite
    }
    
    func fetchFavorites() -> AnyPublisher<[NewsArticle], Error> {
        Future { [weak self] promise in
            self?.coreDataManager.performBackgroundTask { context in
                let request: NSFetchRequest<FavoriteArticle> = FavoriteArticle.fetchRequest()
                request.sortDescriptors = [NSSortDescriptor(key: "favoritedAt", ascending: false)]
                
                do {
                    let favorites = try context.fetch(request)
                    let articles = favorites.compactMap { favorite in
                        self?.convertToNewsArticle(favorite: favorite)
                    }
                    promise(.success(articles))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getFavoritesStatus(for articleIds: [String]) -> AnyPublisher<[String: Bool], Error> {
        Future { [weak self] promise in
            self?.coreDataManager.performBackgroundTask { context in
                
                let request: NSFetchRequest<FavoriteArticle> = FavoriteArticle.fetchRequest()
                let validIds = articleIds.filter { !$0.isEmpty }
                
                guard !validIds.isEmpty else {
                    return promise(.success([:]))
                }
                
                request.predicate = NSPredicate(format: "id IN %@", validIds)
                
                do {
                    let favorites = try context.fetch(request)
                    let favoriteIds = Set(favorites.compactMap { $0.id })
                    
                    let statusDict = Dictionary(
                        uniqueKeysWithValues: articleIds.map { id in
                            // Como articleIds es [String], no necesitamos verificar nil
                            (id, favoriteIds.contains(id))
                        }
                    )
                    promise(.success(statusDict))
                } catch {
                    promise(.failure(FavoritesError.coreDataError(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func convertToNewsArticle(favorite: FavoriteArticle) -> NewsArticle? {
        guard let id = favorite.id,
              let title = favorite.title,
              let urlString = favorite.url,
              let url = URL(string: urlString.absoluteString),
              let publishedAtString = favorite.publishedAt,
              let publishedAt = ISO8601DateFormatter().date(from: publishedAtString) else {
            return nil
        }
        
        return NewsArticle(
            id: id,
            source: NewsSource(
                id: nil,
                name: favorite.sourceName ?? "Unknown"
            ),
            author: favorite.author,
            title: title,
            description: favorite.articleDescription,
            url: url,
            urlToImage: favorite.urlToImage.flatMap(URL.init),
            publishedAt: publishedAt.description,
            content: favorite.content,
            isFavorite: true
        )
    }
}
