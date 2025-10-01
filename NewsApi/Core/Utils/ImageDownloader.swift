//
//  ImageDownloader.swift
//  NewsApi
//
//  Created by Ekaterina Lysova on 29/09/2025.
//


import UIKit

class ImageDownloader {
    static func downloadImageData(from url: URL) async -> Data? {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch {
            print("❌ Failed to download image from \(url): \(error)")
            return nil
        }
    }
}
