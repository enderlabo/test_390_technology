//
//  APIService.swift
//  Test390Technology
//
//  Created by Elderson Laborit on 4/14/25.
//

import Foundation
import Combine
import CoreData

final class APIService: APIServiceProtocol {
    
    private let urlSession: URLSession
    private let jsonDecoder: JSONDecoder
    private let memoryCache: MemoryCacheProtocol
    private let coreDataManager: CoreDataManagerProtocol
    
    private var backgroundRefreshTask: AnyCancellable?
    private let backgroundQueue = DispatchQueue(label: "com.newsapi.background", qos: .background)
    
    init(
        urlSession: URLSession = .shared,
        jsonDecoder: JSONDecoder = JSONDecoder(),
        memoryCache: MemoryCacheProtocol = MemoryCache.shared,
        coreDataManager: CoreDataManagerProtocol = CoreDataManager.shared,
        
    ) {
        self.urlSession = urlSession
        self.jsonDecoder = jsonDecoder
        self.jsonDecoder.dateDecodingStrategy = .iso8601
        self.memoryCache = memoryCache
        self.coreDataManager = coreDataManager
        
    }
    
    // MARK: - Public Interface
    func fetchSportArticles(forceRefresh: Bool = false) -> AnyPublisher<[NewsArticle], Error> {
        let cacheKey = "sport_articles"
        
        if forceRefresh {
            return fetchFromRemote(cacheKey: cacheKey)
        }
        
        return checkMemoryCache(cacheKey: cacheKey)
            .flatMap { articles -> AnyPublisher<[NewsArticle], Error> in
                if let articles = articles {
                    return Just(articles)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                return self.checkCoreDataCache()
                    .flatMap { articles -> AnyPublisher<[NewsArticle], Error> in
                        if !articles.isEmpty {
                            return self.memoryCache.cache(articles, forKey: cacheKey, expiration: 1800)
                                .map { _ in articles }
                                .eraseToAnyPublisher()
                        }
                        return self.fetchFromRemote(cacheKey: cacheKey)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private func checkMemoryCache(cacheKey: String) -> AnyPublisher<[NewsArticle]?, Error> {
        memoryCache.get(forKey: cacheKey)
            .map { articles -> [NewsArticle]? in
                return articles
            }
            .catch { _ in
                Just(nil)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private func checkCoreDataCache() -> AnyPublisher<[NewsArticle], Error> {
        Future { [weak self] promise in
            self?.coreDataManager.performBackgroundTask { context in
                let request: NSFetchRequest<CachedArticle> = CachedArticle.fetchRequest()
                request.sortDescriptors = [NSSortDescriptor(key: "publishedAt", ascending: false)]
                request.fetchLimit = 50
                
                let expirationDate = Date().addingTimeInterval(-86400)
                request.predicate = NSPredicate(format: "cachedAt >= %@", expirationDate as NSDate)
                
                do {
                    let cachedArticles = try context.fetch(request)
                    let articles = cachedArticles.compactMap { $0.toNewsArticle() }
                    promise(.success(articles))
                } catch {
                    promise(.success([]))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func fetchFromRemote(cacheKey: String) -> AnyPublisher<[NewsArticle], Error> {
        let apiKey = APIKeyManager.shared.getAPIKey()
        let endpoint = Endpoint.everything(query: "sport", apiKey: apiKey)
        
        guard let urlRequest = buildRequest(for: endpoint) else {
            return Fail(error: APIError.invalidRequest).eraseToAnyPublisher()
        }
        
        return urlSession.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                guard 200..<300 ~= httpResponse.statusCode else {
                    throw APIError.httpError(statusCode: httpResponse.statusCode, message: APIError.invalidRequest.localizedDescription)
                }
                
                return data
            }
            .decode(type: NewsAPIResponse.self, decoder: jsonDecoder)
            .map { $0.articles.compactMap { $0.toDomain() } }
            .flatMap { articles in
                let saveToMemory = self.memoryCache.cache(articles, forKey: cacheKey, expiration: 900)
                let saveToCoreData = self.saveToCoreData(articles: articles)
                
                return saveToMemory
                    .zip(saveToCoreData)
                    .map { _ in articles }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private func buildRequest(for endpoint: Endpoint) -> URLRequest? {
            var urlComponents = URLComponents(url: endpoint.baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: true)
            urlComponents?.queryItems = endpoint.queryItems
            
            guard let url = urlComponents?.url else { return nil }
            
            var request = URLRequest(url: url)
            request.httpMethod = endpoint.method.rawValue
            endpoint.headers?.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
            
            return request
        }
    
    private func saveToCoreData(articles: [NewsArticle]) -> AnyPublisher<Void, Error> {
        Future { [weak self] promise in
            self?.coreDataManager.performBackgroundTask { context in
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: CachedArticle.fetchRequest())
                
                do {
                    try context.execute(deleteRequest)
                    
                    for article in articles {
                        let cachedArticle = CachedArticle(context: context)
                        cachedArticle.id = article.id ?? UUID().uuidString
                        cachedArticle.title = article.title
                        cachedArticle.articleDescription = article.description
                        cachedArticle.url = article.url
                        cachedArticle.urlToImage = article.urlToImage?.absoluteString
                        cachedArticle.publishedAt = article.publishedAt
                        cachedArticle.sourceName = article.source.name
                        cachedArticle.author = article.author
                        cachedArticle.content = article.content
                        cachedArticle.savedAt = article.shortDate
                    }
                    
                    try context.save()
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
        }
    }
    
extension CachedArticle {
    func toNewsArticle() -> NewsArticle? {
        guard let id = id,
              let title = title,
              let urlString = url,
              let url = URL(string: urlString.absoluteString),
              let sourceName = sourceName else {
            return nil
        }
        
        return NewsArticle(
            id: id,
            source: NewsSource(id: nil, name: sourceName),
            author: author,
            title: title,
            description: articleDescription,
            url: url,
            urlToImage: urlToImage.flatMap(URL.init),
            publishedAt: publishedAt ?? "",
            content: content,
            isFavorite: false
        )
    }
}
