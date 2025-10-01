//
//  HeartButton.swift
//  NewsApi
//
//  Created by Ekaterina Lysova on 01/10/2025.
//

import SwiftUI

struct HeartButton: View {
    
    let article: Article
    @EnvironmentObject var vm: ViewModel

    var body: some View {
        HStack {
            Button {
                Task {
                    if vm.savedArticleURLs.contains(article.url) {
                        await vm.removeArticle(article)
                    } else {
                        await vm.addArticle(article)
                    }
                }
            } label: {
                Image(systemName: vm.savedArticleURLs.contains(article.url) ? "heart.fill" : "heart")
                    .imageScale(.large)
                    .padding(8)
                    .background(.black.opacity(0.5))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .foregroundStyle(.red)
        }
        .padding(8)
    }
}
