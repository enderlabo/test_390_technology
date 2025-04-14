//
//  HomeViewModel.swift
//  Test390Technology
//
//  Created by Elderson Laborit on 4/12/25.
//

import Foundation
import Combine

class NewsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var articles: [NewsArticle] = []
    @Published var isLoading = false
    @Published var error: String?
    
    
    // MARK: - Dependencies
    private let repository: NewsRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    weak var coordinatorDelegate: NewsViewModelCoordinatorDelegate?
    
    // MARK: - Initialization
    init(repository: NewsRepositoryProtocol) {
        self.repository = repository
        setupBindings()
        }
    
    // MARK: - Public Methods
    func fetchNews(forceRefresh: Bool = false) {
            isLoading = true
            error = nil
            
            repository.fetchNews(forceRefresh: forceRefresh)
                .sink { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.error = error.localizedDescription
                        print("Error fetching news: \(error)")
                    }
                } receiveValue: { [weak self] articles in
                    self?.articles = articles
                }
                .store(in: &cancellables)
        }
    
    func toggleFavorite(for articleId: String) {
        guard let index = articles.firstIndex(where: { $0.id == articleId }) else { return }
        let article = articles[index]
            
            repository.toggleFavorite(article: article)
                .sink { completion in
                    if case .failure(let error) = completion {
                        print("Error toggling favorite: \(error)")
                    }
                } receiveValue: { [weak self] updatedArticle in
                    guard let index = self?.articles.firstIndex(where: { $0.id == updatedArticle.id }) else {
                        return
                    }
                    
                    self?.articles[index] = updatedArticle
                }
                .store(in: &cancellables)
        }
    
    func handleRefresh() {
        fetchNews(forceRefresh: true)
    }
    
    func didTapOnArticle(_ article: NewsArticle) {
        coordinatorDelegate?.didSelectArticle(article)
    }
    
    var cellModels: [NewsCellModel] {
        articles.map {
            NewsCellModel(
                title: $0.title,
                author: $0.author ?? "Unknown author",
                imageURL: $0.urlToImage,
                isFavorite: $0.isFavorite
            )
        }
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        Timer.publish(every: 900, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.fetchNews()
            }
            .store(in: &cancellables)
    }
    
}
