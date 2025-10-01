//
//  ArticleRowView.swift
//  NewsApi
//
//  Created by Ekaterina Lysova on 29/09/2025.
//

import SwiftUI

struct ArticleRowView: View {
    let article: Article
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let data = article.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(8)
            } else {
                ZStack {
                    Color(.systemGray5)
                    Image(systemName: "photo.artframe")
                        .imageScale(.large)
                        .foregroundStyle(.gray)
                }
                .frame(height: 200)
                .cornerRadius(8)
            }
            
            Text(article.title ?? "No Title")
                .font(.headline)
                .lineLimit(3)
        }
        .padding(.bottom, 8)
    }
}
