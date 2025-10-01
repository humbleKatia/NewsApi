//
//  Mocks.swift
//  NewsApiTests
//
//  Created by Ekaterina Lysova on 01/10/2025.
//

@testable import NewsApi
import Foundation

class MockNewsRepository: NewsServiceProtocol {
    
    var articlesToReturn: [Article]?
    var errorToThrow: Error?
    
    func fetchLatestNews() async throws -> [Article] {
        if let error = errorToThrow {
            throw error
        }
        return articlesToReturn ?? []
    }
    
}

class MockDBManager: DBManagerProtocol {
    
    var articlesDB = [Article]()
    var savedArticlesDB = [Article]()
    
    var saveArticlesCalled = false
    var saveArticleToSavedViewCalled = false
    var deleteSavedArticleCalled = false
    
    func saveArticles(_ articles: [Article]) async throws {
        saveArticlesCalled = true
        self.articlesDB.append(contentsOf: articles)
    }
    
    func fetchArticles() async throws -> [Article] {
        return articlesDB
    }
    
    func updateArticle(url: String, with imageData: Data) async throws {
        // Not testing this logic for now, so we can leave it empty
    }
    
    func saveArticleToSavedView(_ article: Article) async throws {
        saveArticleToSavedViewCalled = true
        savedArticlesDB.append(article)
    }
    
    func fetchSavedArticles() async throws -> [Article] {
        return savedArticlesDB
    }
    
    func deleteSavedArticle(_ article: Article) async throws {
        deleteSavedArticleCalled = true
        savedArticlesDB.removeAll {$0.url == article.url}
    }
    
    
}
