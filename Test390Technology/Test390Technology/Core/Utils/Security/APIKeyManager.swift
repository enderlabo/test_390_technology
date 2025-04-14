//
//  APIKeyManager.swift
//  Test390Technology
//
//  Created by Elderson Laborit on 4/14/25.
//

final class APIKeyManager {
    static let shared = APIKeyManager()
    private let service = "com.tuapp.newsapi"
    private let account = "apiKey"
    
    private init() {}
    
    func configureAPIKey() {
        #if DEBUG
        let debugKey = "2b624d8607744c6095168c1f2bbc2def"
        #else
        guard let productionKey = Bundle.main.object(forInfoDictionaryKey: "NEWS_API_KEY") as? String else {
            fatalError("API not configured in Info.plist")
        }
        #endif
        
        do {
            let _ = try KeychainHandler.shared.get(service: service, account: account)
        } catch KeychainError.itemNotFound {
            do {
                #if DEBUG
                try KeychainHandler.shared.save(service: service, account: account, value: debugKey)
                #else
                try KeychainHandler.shared.save(service: service, account: account, value: productionKey)
                #endif
            } catch {
                print("Error save API Key: \(error)")
            }
        } catch {
            print("Error fetch API Key: \(error)")
        }
    }
    
    func getAPIKey() -> String {
        do {
            return try KeychainHandler.shared.get(service: service, account: account)
        } catch {
            fatalError("Cant get API Key: \(error)")
        }
    }
}
