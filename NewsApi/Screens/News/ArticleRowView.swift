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
        GeometryReader { geometry in
            Group {
                if let data = article.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: 200)
                        .clipped()
                } else {
                    ZStack {
                        Color(.systemGray5)
                        Image(systemName: "photo.artframe")
                            .imageScale(.large)
                            .foregroundStyle(.gray)
                    }
                    .frame(width: geometry.size.width, height: 200)
                }
            }
            .overlay(alignment: .bottom) {
                  VStack(alignment: .leading) {
                      Text(article.title ?? "No Title")
                          .font(.headline)
                          .lineLimit(2)
                          .foregroundColor(.primary)
                  }
                  .padding(10)
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .background(.ultraThinMaterial)
              }
            .cornerRadius(8)
            .overlay(alignment: .topTrailing) {
                HeartButton(article: article)
            }
        }
        .frame(height: 200) 
    }
}
