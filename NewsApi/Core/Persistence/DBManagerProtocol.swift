//
//  DBManagerProtocol.swift
//  NewsApi
//
//  Created by Ekaterina Lysova on 01/10/2025.
//

import UIKit

protocol DBManagerProtocol {
    func saveArticles(_ articles: [Article]) async throws
    func fetchArticles() async throws -> [Article]
    func updateArticle(url: String, with imageData: Data) async throws
    
    func saveArticleToSavedView(_ article: Article) async throws
    func fetchSavedArticles() async throws -> [Article]
    func deleteSavedArticle(_ article: Article) async throws
}
