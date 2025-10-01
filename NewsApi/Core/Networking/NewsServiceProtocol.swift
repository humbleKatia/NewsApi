//
//  NewsServiceProtocol.swift
//  NewsApi
//
//  Created by Ekaterina Lysova on 01/10/2025.
//

import UIKit

protocol NewsServiceProtocol {
    func fetchLatestNews() async throws -> [Article]
}
