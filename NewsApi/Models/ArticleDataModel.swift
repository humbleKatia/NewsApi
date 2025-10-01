//
//  ArticleDataModel.swift
//  NewsApi
//
//  Created by Ekaterina Lysova on 30/09/2025.
//

import UIKit

struct APIResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

struct Article: Codable, Identifiable {
    let source: Source
    let author: String?
    let title: String?
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String?
    let content: String?
    
    var imageData: Data?
    
    var id: String { url }
}

struct Source: Codable {
    var id: String?
    var name: String?
}

