//
//  CoreDataManager.swift
//  NewsApi
//
//  Created by Ekaterina Lysova on 16/09/2025.
//


import CoreData
import UIKit

protocol DBManagedProtocol {
    func saveArticles(_ articles: [Article]) async
    func fetchArticle() -> [Article]
    
    func addArticleToSaved(_ article: Article) async
    func fetchSavedArticle() -> [Article]
    func deleteSavedArticle(_ article: Article) async
}

class CoreDataManager: DBManagedProtocol {
    
    static let shared = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NewsModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            } else {
                print("successfully loaded Core Data")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    
    init() {}
    
    
    func saveArticles(_ articles: [Article]) async {
        let context = persistentContainer.viewContext
        
        for article in articles {
            let entity = ArticleEntity(context: context)
            
            entity.url = article.url
            
            entity.title = article.title
            entity.author = article.author
            entity.articleDescription = article.description
            entity.urlToImage = article.urlToImage
            entity.publishedAt = article.publishedAt
            entity.content = article.content
            entity.sourceName = article.source.name
            
            if let urlString = article.urlToImage,
               let url = URL(string: urlString) {
                await self.downloadImageData(for: article.url, from: url)
            }
            do {
                try context.save()
                print("💾 Saved \(article.title) articles (without images).")
                print("✅ Saved image for: \(entity.title ?? "unknown")")
            } catch {
                print("❌ Failed to save articles: \(error)")
            }
            
        }
        
        
    }
    
    
    
    private func downloadImageData(for articleURL: String, from url: URL) async {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            let context = persistentContainer.viewContext
            let request: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
            request.predicate = NSPredicate(format: "url == %@", articleURL)
            
            if let entity = try? context.fetch(request).first {
                entity.imageData = data
            }
        } catch {
            print("❌ Failed to download image: \(error)")
        }
    }
    
    
    func fetchArticle() -> [Article] {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \ArticleEntity.publishedAt, ascending: false)
        ]
        do {
            let entities = try context.fetch(request)
            return entities.map { entity in
                
                Article(
                    source: Source(name: entity.sourceName ?? ""),
                    author: entity.author,
                    title: entity.title ?? "",
                    description: entity.articleDescription,
                    url: entity.url ?? "",
                    urlToImage: entity.urlToImage,
                    publishedAt: entity.publishedAt ?? "",
                    content: entity.content,
                    imageData: entity.imageData  // Add this line
                )
            }
        } catch {
            print("❌ Failed to fetch articles: \(error)")
            return []
        }
    }
    
    
    // MARK: - Saved Articles
    func addArticleToSaved(_ article: Article) async {
        let context = persistentContainer.viewContext
        let entity = SavedArticleEntity(context: context)
        entity.url = article.url
        
        entity.title = article.title
        entity.author = article.author
        entity.articleDescription = article.description
        entity.urlToImage = article.urlToImage
        entity.publishedAt = article.publishedAt
        entity.content = article.content
        entity.sourceName = article.source.name
        
        if let urlString = article.urlToImage,
           let url = URL(string: urlString) {
            await self.downloadImageDataToSaved(for: article.url, from: url)
        }
        do {
            try context.save()
            print("💾 Added new article (without images).")
            print("✅ Saved image for Added new article ")
        } catch {
            print("❌ Failed to save article: \(error)")
        }
        
    }
    
    
    private func downloadImageDataToSaved(for articleURL: String, from url: URL) async {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            let context = persistentContainer.viewContext
            let request: NSFetchRequest<SavedArticleEntity> = SavedArticleEntity.fetchRequest()
            request.predicate = NSPredicate(format: "url == %@", articleURL)
            
            if let entity = try? context.fetch(request).first {
                entity.imageData = data
            }
        } catch {
            print("❌ Failed to download image: \(error)")
        }
    }
    
    
    
    func fetchSavedArticle() -> [Article] {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<SavedArticleEntity> = SavedArticleEntity.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \SavedArticleEntity.publishedAt, ascending: false)
        ]
        
        do {
            let entities = try context.fetch(request)
            return entities.map { entity in
                Article(
                    source: Source(name: entity.sourceName ?? ""),
                    author: entity.author,
                    title: entity.title ?? "",
                    description: entity.articleDescription,
                    url: entity.url ?? "",
                    urlToImage: entity.urlToImage,
                    publishedAt: entity.publishedAt ?? "",
                    content: entity.content,
                    imageData: entity.imageData
                )
            }
        } catch {
            print("❌ Failed to fetch saved articles: \(error)")
            return []
        }
        
    }
    
    
    
    func deleteSavedArticle(_ article: Article) async {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<SavedArticleEntity> = SavedArticleEntity.fetchRequest()
        request.predicate = NSPredicate(format: "url == %@", article.url)
        do {
            if let entity = try context.fetch(request).first {
                context.delete(entity)
                try context.save()
                print("🗑️ Deleted saved article: \(article.title)")
            }
        } catch {
            print("❌ Failed to delete saved article: \(error)")
        }
    }
    
    
}

