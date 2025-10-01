//
//  CoreDataManager.swift
//  NewsApi
//
//  Created by Ekaterina Lysova on 16/09/2025.
//

import CoreData
import UIKit

class CoreDataManager: DBManagerProtocol {
    
    static let shared = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NewsModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("❌ Failed to load Core Data: \(error)")
            } else {
                print("✅ Successfully loaded Core Data")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    
    init() {}
    
    private func saveContext(context: NSManagedObjectContext) throws {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                throw NewsError.databaseError(" ❌ Failed to save context: \(error.localizedDescription)")
            }
        }
    }
    
    func saveArticles(_ articles: [Article]) async throws {
        try await persistentContainer.performBackgroundTask { context in
            for article in articles {
                let entity = ArticleEntity(context: context)
                entity.url = article.url
                entity.title = article.title
                entity.author = article.author
                entity.articleDescription = article.description
                entity.urlToImage = article.urlToImage
                entity.publishedAt = article.publishedAt
                entity.content = article.content
                entity.sourceName = article.source.name ?? ""
            }
            try self.saveContext(context: context)
            print("✅ Articles saved: \(articles.count)")
        }
    }
    
    func updateArticle(url: String, with imageData: Data) async throws {
        try await persistentContainer.performBackgroundTask { context in
            let request = ArticleEntity.fetchRequest()
            request.predicate = NSPredicate(format: "url == %@", url)
            
            if let entity = try context.fetch(request).first {
                entity.imageData = imageData
                try self.saveContext(context: context)
                print("✅ Saved image for article: \(url)")
            }
        }
    }
    
    func fetchArticles() async throws -> [Article] {
        let context = persistentContainer.viewContext
        let request = ArticleEntity.fetchRequest()
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
                    imageData: entity.imageData
                )
            }
        } catch {
            throw NewsError.databaseError("❌ Failed to fetch articles.")
        }
    }
    
    // MARK: - Saved Articles
    func saveArticleToSavedView(_ article: Article) async throws {
        try await persistentContainer.performBackgroundTask { context in
            let entity = SavedArticleEntity(context: context)
            entity.url = article.url
            
            entity.title = article.title
            entity.author = article.author
            entity.articleDescription = article.description
            entity.urlToImage = article.urlToImage
            entity.publishedAt = article.publishedAt
            entity.content = article.content
            entity.sourceName = article.source.name
            entity.imageData = article.imageData
            try self.saveContext(context: context)
            print("✅ SavedArticleEntity saved")
        }
    }
    
    func fetchSavedArticles() async throws -> [Article] {
        let context = persistentContainer.viewContext
        let request = SavedArticleEntity.fetchRequest()
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
            throw NewsError.databaseError("❌ Failed to fetch saved articles.")
        }
    }
    
    func deleteSavedArticle(_ article: Article) async throws {
        try await persistentContainer.performBackgroundTask { context in
            let request = SavedArticleEntity.fetchRequest()
            request.predicate = NSPredicate(format: "url == %@", article.url)
            
            if let entity = try context.fetch(request).first {
                context.delete(entity)
                try self.saveContext(context: context)
                print("🚮 SavedArticle deleted")
            }
        }
    }
    
}


