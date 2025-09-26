//
//  NewsRepository.swift
//  NewsApi
//
//  Created by Ekaterina Lysova on 20/09/2025.
//

import UIKit

protocol NewsServiceProtocol {
    func fetchLatestNews(coreDataManager: DBManagedProtocol) async -> Bool
}

class NewsRepository: NewsServiceProtocol {
    private let newsService: NewsService
    
    
    init(newsService: NewsService = .shared) {
        self.newsService = newsService
    }
    
    func fetchLatestNews(coreDataManager: DBManagedProtocol) async -> Bool {
        do {
            let freshArticles = try await newsService.fetchNews()
            let cached = coreDataManager.fetchArticle()
            let cachedURLs = Set(cached.compactMap { $0.url })
            //            print("🔍 Cached URLs: \(cachedURLs)")
            //            print("🔍 Fresh URLs: \(freshArticles.map { $0.url })")
            //            print("🔍 Fresh articles count: \(freshArticles.count), Cached articles count: \(cached.count)")
            let newOnes = freshArticles.filter { !cachedURLs.contains($0.url) }
            print("🔍 New articles: \(newOnes.map { $0.url })")
            
            if !newOnes.isEmpty {
                await coreDataManager.saveArticles(newOnes)
                return true
            } else {
                print("ℹ️ No new articles to save")
                return false
            }
        } catch {
            print("❌ Repository failed to fetch news: \(error)")
            return false
        }
    }
    
}

