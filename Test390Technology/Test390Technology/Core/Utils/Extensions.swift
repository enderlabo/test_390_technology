//
//  Extensions.swift
//  Test390Technology
//
//  Created by Elderson Laborit on 4/14/25.
//

import Foundation

extension String {
    func stableHash() -> String {
        let data = Data(self.utf8)
        let hash = data.withUnsafeBytes { bytes -> UInt64 in
            var hash: UInt64 = 5381
            for byte in bytes {
                hash = 127 * (hash & 0x00ffffffffffffff) + UInt64(byte)
            }
            return hash
        }
        return String(hash)
    }
}

extension NewsArticle {
    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return publishedAt
    }
    
    var sourceName: String {
        source.name.isEmpty ? "Unknown Source" : source.name
    }
    
    var displayAuthor: String {
        author ?? sourceName
    }
}

//MARK: - Coordinators Protocols
extension NewsCoordinator: NewsViewModelCoordinatorDelegate {
    func didEncounterError(_ error: any Error) {
        print("Error: \(error)")
    }
    
    func didSelectArticle(_ article: NewsArticle) {
        showArticleDetail(article)
    }
}
