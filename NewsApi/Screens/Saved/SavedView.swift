//
//  SavedView.swift
//  NewsApi
//
//  Created by Ekaterina Lysova on 25/09/2025.
//

import SwiftUI

struct SavedView: View {
    
    @EnvironmentObject var vm: ViewModel
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(vm.savedArticles) { article in
                    ZStack {
                        if let url = URL(string: article.url) {
                            Link(destination: url) {
                                EmptyView()
                            }
                        }
                        ArticleRowView(article: article)
                    }
                    .overlay(alignment: .topTrailing) {
                        HeartButton(article: article)
                    }
                    .listRowInsets(.init(top: 0, leading: 10, bottom: 0, trailing: 10))
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Saved News")
            .navigationBarTitleDisplayMode(.inline)
            .overlay {
                if vm.savedArticles.isEmpty {
                    ContentUnavailableView("No Saved Articles", systemImage: "bookmark", description: Text("Save articles from the main feed to see them here."))
                }
            }
        }
    }
}
