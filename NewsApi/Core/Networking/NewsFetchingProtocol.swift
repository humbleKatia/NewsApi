//
//  NewsFetchingProtocol.swift
//  NewsApi
//
//  Created by Ekaterina Lysova on 01/10/2025.
//

import UIKit

protocol NewsFetchingProtocol {
    func fetchNews() async throws -> [Article]
}
