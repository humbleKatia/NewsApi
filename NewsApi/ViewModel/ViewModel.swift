//
//  ViewModel.swift
//  NewsApi
//
//  Created by Ekaterina Lysova on 30/08/2025.
//

import UIKit
import SwiftUI




struct APIResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

struct Article: Codable, Identifiable {
    let source: Source
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
    let content: String?
    
    let imageData: Data?
    
    var id: String { url }
}

struct Source: Codable {
    var id: String?
    var name: String
}


@MainActor
class ViewModel: ObservableObject {
    
    @Published var isLoading = false
    
    @Published var articles = [Article]()
    @Published var savedArticles = [Article]()
    
    
    let repository: NewsServiceProtocol
    let coreDataManager:  DBManagedProtocol
    
    init(repository: NewsServiceProtocol, coreDataManager: DBManagedProtocol)  {
        self.repository = repository
        
        self.coreDataManager = coreDataManager
        articles = coreDataManager.fetchArticle()
        savedArticles = coreDataManager.fetchSavedArticle()
    }
    
    
    func fetchLatestNews() async {
        isLoading = true
        defer { isLoading = false }
        
        let hasNew = await repository.fetchLatestNews(coreDataManager: coreDataManager)
        
        if hasNew {
            print("✅ Background fetch and save completed successfully.")
            self.articles = coreDataManager.fetchArticle()
            
            UserNotificationManager.shared.sendNotification(
                title: "New articles",
                message: "Check out the latest headlines."
            )
        } else {
            print("ℹ️ No new articles to save from background fetch.")
            UserNotificationManager.shared.sendNotification(
                title: "No new articles",
                message: "You're all caught up."
            )
        }
        
    }
    
    func addArticle(_ article: Article) async {
        await coreDataManager.addArticleToSaved(article)
        savedArticles = coreDataManager.fetchSavedArticle()
    }
    
    
    func removeArticle(_ article: Article) async {
        await coreDataManager.deleteSavedArticle(article)
        savedArticles = coreDataManager.fetchSavedArticle()
    }
    
}


