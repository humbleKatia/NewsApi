//
//  ViewModel.swift
//  NewsApi
//
//  Created by Ekaterina Lysova on 30/08/2025.
//

import UIKit
import SwiftUI

@MainActor
class ViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var articles = [Article]()
    @Published var savedArticles = [Article]()
    @Published var savedArticleURLs = Set<String>()
    @Published var alertItem: AlertItem?
    
    private let repository: NewsServiceProtocol
    private let coreDataManager: DBManagerProtocol
    
    init(repository: NewsServiceProtocol, coreDataManager: DBManagerProtocol) {
        self.repository = repository
        self.coreDataManager = coreDataManager
        Task {
            await loadInitialData()
        }
    }
    
    private func loadInitialData() async {
        do {
            self.articles = try await coreDataManager.fetchArticles()
            self.savedArticles = try await coreDataManager.fetchSavedArticles()
            updateSavedURLsSet()
            guard !self.articles.isEmpty else {
                print("Articles are empty, fetching new ones")
                await fetchLatestNews()
                return
            }
            print("✅ ArticleEntities: \(articles.count) and SavedArticleEntity: \(savedArticles.count) fetched from Core Data:")
        } catch let error as NewsError {
            alertItem = AlertItem(title: "Loading Error", message: error.localizedDescription)
        } catch {
            alertItem = AlertItem(title: "Error", message: "An unknown error occurred during startup.")
        }
    }
    
    func fetchLatestNews() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let freshArticles = try await repository.fetchLatestNews()
            let cachedArticles = try await coreDataManager.fetchArticles()
            let cachedURLs = Set(cachedArticles.map { $0.url })
            let newArticles = freshArticles.filter { !cachedURLs.contains($0.url) }
            if !newArticles.isEmpty {
                try await coreDataManager.saveArticles(newArticles)
                self.articles = try await coreDataManager.fetchArticles()
                await downloadImages(for: self.articles)
                UserNotificationManager.shared.sendNotification(
                    title: "New articles",
                    message: "Check out the latest headlines."
                )
            } else {
                print("ℹ️ No new articles found.")
            }
        } catch let error as NewsError {
            alertItem = AlertItem(title: "Failed to Fetch News", message: error.localizedDescription)
        } catch {
            alertItem = AlertItem(title: "Error", message: "An unexpected error occurred.")
        }
    }
    
    private func downloadImages(for articles: [Article]) async {
        let articlesWithoutImages = articles.filter { $0.imageData == nil && $0.urlToImage != nil }
        await withTaskGroup(of: (String, Data?).self) { group in
            for article in articlesWithoutImages {
                guard let urlString = article.urlToImage, let url = URL(string: urlString) else { continue }
                group.addTask {
                    let data = await ImageDownloader.downloadImageData(from: url)
                    return (article.url, data)
                }
            }
            for await (articleURL, imageData) in group {
                if let imageData = imageData {
                    do {
                        try await coreDataManager.updateArticle(url: articleURL, with: imageData)
                        if let index = self.articles.firstIndex(where: { $0.url == articleURL }) {
                            self.articles[index].imageData = imageData
                        }
                    } catch {
                        print("Failed to save image for \(articleURL)")
                    }
                }
            }
        }
    }
    
    func addArticle(_ article: Article) async {
        do {
            try await coreDataManager.saveArticleToSavedView(article)
            savedArticles.insert(article, at: 0)
            updateSavedURLsSet()
        } catch let error as NewsError {
            alertItem = AlertItem(title: "Save Error", message: error.localizedDescription)
        } catch {
            alertItem = AlertItem(title: "Error", message: "Could not save the article.")
        }
    }
    
    func removeArticle(_ article: Article) async {
        do {
            try await coreDataManager.deleteSavedArticle(article)
            savedArticles.removeAll { $0.id == article.id }
            updateSavedURLsSet()
        } catch let error as NewsError {
            alertItem = AlertItem(title: "Delete Error", message: error.localizedDescription)
        } catch {
            alertItem = AlertItem(title: "Error", message: "Could not remove the article.")
        }
    }
    
    private func updateSavedURLsSet() {
        savedArticleURLs = Set(savedArticles.map { $0.url })
    }
    
}
