//
//  NewsCellViewModelProtocol.swift
//  Test390Technology
//
//  Created by Elderson Laborit on 4/14/25.
//

import Foundation
import Combine

protocol NewsCellViewModelProtocol {
    var title: String { get }
    var author: String { get }
    var imageURL: URL? { get }
    var isFavorite: Bool { get }
    var onFavoriteToggle: AnyPublisher<Bool, Never> { get }
}
