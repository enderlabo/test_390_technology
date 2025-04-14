//
//  NewsCell.swift
//  Test390Technology
//
//  Created by Elderson Laborit on 4/14/25.
//

import UIKit
import Kingfisher
import Combine

final class NewsCell: UITableViewCell {
    static let reuseIdentifier = String(describing: NewsCell.self)
    
    // MARK: - UI Components
    private let headlineLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.numberOfLines = 2
        label.textColor = .label
        label.accessibilityLabel = "Headline"
        label.accessibilityIdentifier = "headlineLabel"
        return label
    }()
    
    private let sourceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        label.accessibilityLabel = "Source"
        label.accessibilityIdentifier = "sourceLabel"
        return label
    }()
    
    
    private let articleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()
    
    private let favoriteIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemRed
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var labelsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [headlineLabel, sourceLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        headlineLabel.text = nil
        sourceLabel.text = nil
        articleImageView.image = nil
        favoriteIcon.isHidden = true
        favoriteIcon.image = nil
    }
    
    // MARK: - Properties
       private var viewModel: NewsCellViewModelProtocol?
       private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Configuration
    func configure(with model: NewsArticle) {
        headlineLabel.text = model.title
        sourceLabel.text = model.author
        
        favoriteIcon.isHidden = !model.isFavorite
        favoriteIcon.image = model.isFavorite ? UIImage(systemName: "heart.fill") : nil
        
        if let imageURL = model.urlToImage {
            let processor = DownsamplingImageProcessor(size: articleImageView.bounds.size)
            articleImageView.kf.setImage(
                with: imageURL,
                options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(0.3)),
                    .cacheOriginalImage,
                    .backgroundDecode
                ],
                completionHandler: { [weak self] result in
                    if case .failure = result {
                        self?.setPlaceholderImage()
                    }
                }
            )
        } else {
            setPlaceholderImage()
        }
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor.systemGray5
        self.selectedBackgroundView = selectedBackgroundView
        
        contentView.addSubview(labelsStack)
        contentView.addSubview(articleImageView)
        contentView.addSubview(favoriteIcon)
        
        NSLayoutConstraint.activate([
            articleImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            articleImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            articleImageView.widthAnchor.constraint(equalToConstant: 80),
            articleImageView.heightAnchor.constraint(equalToConstant: 60),
            articleImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            favoriteIcon.centerYAnchor.constraint(equalTo: sourceLabel.centerYAnchor),
            favoriteIcon.trailingAnchor.constraint(equalTo: articleImageView.trailingAnchor, constant: 8),
            favoriteIcon.widthAnchor.constraint(equalToConstant: 24),
            favoriteIcon.heightAnchor.constraint(equalToConstant: 24),
            
            headlineLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            headlineLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            headlineLabel.trailingAnchor.constraint(equalTo: articleImageView.leadingAnchor, constant: -12),
            
            sourceLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 4),
            sourceLabel.leadingAnchor.constraint(equalTo: headlineLabel.leadingAnchor),
            sourceLabel.trailingAnchor.constraint(equalTo: favoriteIcon.leadingAnchor, constant: -8),
            sourceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    private func setPlaceholderImage() {
        articleImageView.image = UIImage(systemName: "photo")
        articleImageView.tintColor = .secondaryLabel
    }
}

