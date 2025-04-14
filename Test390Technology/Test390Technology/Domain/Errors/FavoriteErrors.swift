//
//  FavoriteErrors.swift
//  Test390Technology
//
//  Created by Elderson Laborit on 4/13/25.
//

import Foundation

enum FavoritesError: Error {
    case invalidID
    case coreDataError(Error)
    case objectNotFound
    case invalidArticle
    case emptyID
    
    var localizedDescription: String {
        switch self {
        case .invalidID:
            return "El ID del artículo no es válido"
        case .coreDataError(let error):
            return "Error en CoreData: \(error.localizedDescription)"
        case .objectNotFound:
            return "Objeto no encontrado en la base de datos"
        case .invalidArticle:
            return "El artículo no contiene datos válidos"
        case .emptyID:
            return "El ID no puede estar vacío"
        }
    }
}
