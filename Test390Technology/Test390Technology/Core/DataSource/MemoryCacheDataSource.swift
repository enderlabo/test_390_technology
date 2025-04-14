//
//  MemoryCacheDataSource.swift
//  Test390Technology
//
//  Created by Elderson Laborit on 4/14/25.
//

import Foundation
import Combine

struct CachedObject<T: Codable>: Codable {
    let object: T
    let timestamp: Date
    let expirationInterval: TimeInterval
    
    var isExpired: Bool {
        Date().timeIntervalSince(timestamp) > expirationInterval
    }
}

protocol MemoryCacheProtocol {
    func cache<T: Codable>(_ object: T, forKey key: String, expiration: TimeInterval) -> AnyPublisher<Void, Error>
    func get<T: Codable>(forKey key: String) -> AnyPublisher<T?, Error>
    func remove(forKey key: String) -> AnyPublisher<Void, Error>
    func isCacheValid(forKey key: String) -> AnyPublisher<Bool, Error>
}

final class MemoryCache: MemoryCacheProtocol {
    static let shared = MemoryCache()
    private let cache = NSCache<NSString, NSData>()
    private let queue = DispatchQueue(label: "com.memorycache.queue", attributes: .concurrent)
    
    private init() {}
    
    func cache<T: Codable>(_ object: T, forKey key: String, expiration: TimeInterval) -> AnyPublisher<Void, Error> {
        Future { [weak self] promise in
            self?.queue.async(flags: .barrier) {
                let cachedObject = CachedObject(
                    object: object,
                    timestamp: Date(),
                    expirationInterval: expiration
                )
                
                do {
                    let encoded = try JSONEncoder().encode(cachedObject)
                    self?.cache.setObject(encoded as NSData, forKey: key as NSString)
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func get<T: Codable>(forKey key: String) -> AnyPublisher<T?, Error> {
        Future { [weak self] promise in
            self?.queue.async {
                guard let data = self?.cache.object(forKey: key as NSString) as Data? else {
                    return promise(.success(nil))
                }
                
                do {
                    let cachedObject = try JSONDecoder().decode(CachedObject<T>.self, from: data)
                    promise(.success(cachedObject.isExpired ? nil : cachedObject.object))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func remove(forKey key: String) -> AnyPublisher<Void, Error> {
        Future { [weak self] promise in
            self?.queue.async(flags: .barrier) {
                self?.cache.removeObject(forKey: key as NSString)
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func isCacheValid(forKey key: String) -> AnyPublisher<Bool, Error> {
        Future { [weak self] promise in
            self?.queue.async {
                guard let data = self?.cache.object(forKey: key as NSString) as Data? else {
                    return promise(.success(false))
                }
                
                do {
                    let cachedObject = try JSONDecoder().decode(CachedObject<Bool>.self, from: data)
                    promise(.success(!cachedObject.isExpired))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}


