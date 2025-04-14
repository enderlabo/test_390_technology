//
//  HomeView.swift
//  Test390Technology
//
//  Created by Elderson Laborit on 4/14/25.
//

import UIKit
import Combine

final class NewsViewController: UIViewController {
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(NewsCell.self, forCellReuseIdentifier: NewsCell.reuseIdentifier)
        table.delegate = self
        table.dataSource = self
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 120
        table.refreshControl = refreshControl
        return table
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return control
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var customErrorView: CustomErrorView = {
        let view = CustomErrorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.onRetry = { [weak self] in
            self?.retryFetchingData()
        }
        return view
    }()
    
    // MARK: - Properties
    let viewModel: NewsViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(viewModel: NewsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.fetchNews()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "News Sports"
        
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(customErrorView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            customErrorView.topAnchor.constraint(equalTo: view.topAnchor),
            customErrorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customErrorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customErrorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            
        ])
    }
    
    private func bindViewModel() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                isLoading ? self?.loadingIndicator.startAnimating() : self?.loadingIndicator.stopAnimating()
                if !isLoading {
                    self?.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$articles
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$error
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.showErrorView(message: errorMessage)
            }
            .store(in: &cancellables)
    }
    
    
    
    // MARK: - Actions
    @objc private func refreshData() {
        viewModel.fetchNews(forceRefresh: true)
    }
    
    private func showErrorView(message: String) {
        customErrorView.isHidden = false
        customErrorView.configure(message: message)
        tableView.isHidden = true
    }

    @objc private func retryFetchingData() {
        customErrorView.isHidden = true
        
        tableView.isHidden = false
        
        viewModel.fetchNews(forceRefresh: true)
    }
}

// MARK: - UITableView DataSource & Delegate
extension NewsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NewsCell.reuseIdentifier,
            for: indexPath
        ) as? NewsCell else {
            return UITableViewCell()
        }
        
        let article = viewModel.articles[indexPath.row]
        cell.configure(with: article)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let article = viewModel.articles[indexPath.row]
        viewModel.didTapOnArticle(article)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let article = viewModel.articles[indexPath.row]
        
        let favoriteAction = UIContextualAction(
            style: .normal,
            title: nil
        ) { [weak self] _, _, completion in
            self?.viewModel.toggleFavorite(for: article.id ?? "")
            completion(true)
        }
        
        favoriteAction.image = UIImage(
            systemName: article.isFavorite ? "heart.slash" : "heart"
        )?.withTintColor(.white, renderingMode: .alwaysOriginal)
        
        favoriteAction.backgroundColor = article.isFavorite ? .systemGray : .systemPink
        
        let config = UISwipeActionsConfiguration(actions: [favoriteAction])
        config.performsFirstActionWithFullSwipe = true
        return config
    }
}
