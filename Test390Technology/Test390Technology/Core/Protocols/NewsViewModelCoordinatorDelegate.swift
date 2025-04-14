//
//  NewsViewModelCoordinatorDelegate.swift
//  Test390Technology
//
//  Created by Elderson Laborit on 4/14/25.
//

import Foundation

protocol NewsViewModelCoordinatorDelegate: AnyObject {
    func didSelectArticle(_ article: NewsArticle)
    func didEncounterError(_ error: Error)
}
