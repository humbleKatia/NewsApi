//
//  NewsRepository.swift
//  NewsApi
//
//  Created by Ekaterina Lysova on 20/09/2025.

import UIKit

class NewsRepository: NewsServiceProtocol {
    
    private let newsService: NewsService
    
    init(newsService: NewsService = .shared) {
        self.newsService = newsService
    }
    
    func fetchLatestNews() async throws -> [Article] {
        try await newsService.fetchNews()
    }
    
}

