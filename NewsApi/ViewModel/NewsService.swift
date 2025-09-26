//
//  NewsService.swift
//  NewsApi
//
//  Created by Ekaterina Lysova on 10/09/2025.
//

import UIKit
import SwiftUI
import BackgroundTasks

class NewsService {
    static let shared = NewsService()
    let endpoint = "https://newsapi.org/v2/top-headlines"

    private lazy var apiKey: String = {
        guard let filePath = Bundle.main.path(forResource: "secrets", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: filePath),
              let apiKey = plist.object(forKey: "newsKey") as? String else {
            fatalError("secrets.plist not found or 'newsKey' is missing.")
        }
        return apiKey
    }()
    
    init() {}
    
    func fetchNews() async throws -> [Article] {
        guard var components = URLComponents(string: endpoint) else { throw URLError(.badURL) }
        components.queryItems = [
            URLQueryItem(name: "country", value: "us"),
            URLQueryItem(name: "apiKey", value: apiKey)
        ]
        guard let url = components.url else { throw URLError(.badURL) }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)
        print("📡 Fetched \(apiResponse.articles.count) articles from network.")
        return apiResponse.articles
    }
    
}
