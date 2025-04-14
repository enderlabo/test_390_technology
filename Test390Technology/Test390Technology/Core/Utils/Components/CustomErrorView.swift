//
//  CustomErrorView.swift
//  Test390Technology
//
//  Created by Elderson Laborit on 4/14/25.
//

import Foundation
import UIKit

final class CustomErrorView: UIView {
    private let iconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "exclamationmark.triangle.fill"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .systemRed
        return imageView
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let retryButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Retry"
        config.baseBackgroundColor = .tertiarySystemGroupedBackground
        config.baseForegroundColor = .systemBlue
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 25, bottom: 12, trailing: 25)
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.layer.shadowColor = UIColor.label.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 3
        button.layer.shadowOpacity = 0.1
        return button
    }()
    
    var onRetry: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.systemBackground.withAlphaComponent(0.7)
        setupUI()
        registerForTraitChanges()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(message: String) {
        messageLabel.text = message
        animateIcon()
    }

    private func setupUI() {
        addSubview(iconView)
        addSubview(messageLabel)
        addSubview(retryButton)

        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -30),
            iconView.widthAnchor.constraint(equalToConstant: 50),
            iconView.heightAnchor.constraint(equalToConstant: 50),
            
            messageLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 10),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

            retryButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
            retryButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            retryButton.heightAnchor.constraint(equalToConstant: 44),
            retryButton.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
    }

    @objc private func retryTapped() {
        onRetry?()
    }

    private func animateIcon() {
        iconView.layer.removeAllAnimations()
            
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = 1.3
        animation.duration = 0.5
        animation.autoreverses = true
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.repeatCount = .greatestFiniteMagnitude
        
        iconView.layer.add(animation, forKey: "scaleAnimation")
    }
    
    private func registerForTraitChanges() {
        registerForTraitChanges(
            [UITraitUserInterfaceStyle.self],
            action: #selector(updateColorsForCurrentInterfaceStyle)
        )
    }

    @objc private func updateColorsForCurrentInterfaceStyle() {
            UIView.animate(withDuration: 0.3) {
                self.retryButton.layer.borderColor = UIColor.systemBlue.cgColor
                self.retryButton.layer.shadowColor = UIColor.label.cgColor
                self.iconView.tintColor = .systemRed
            }
        }
}
