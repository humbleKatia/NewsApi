//
//  NewsView.swift
//  NewsApi
//
//  Created by Ekaterina Lysova on 30/08/2025.
//

import SwiftUI

struct NewsView: View {
    
    @EnvironmentObject var vm: ViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    ForEach(vm.articles) { article in
                        ZStack {
                            if let url = URL(string: article.url) {
                                Link(destination: url) {
                                    EmptyView()
                                }.opacity(0)
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
                .navigationTitle("Latest News")
                .navigationBarTitleDisplayMode(.inline)
                .task {
                    await UserNotificationManager.shared.requestNotificationPermission()
                }
                .refreshable {
                    await vm.fetchLatestNews()
                }
                if vm.isLoading {
                    ZStack {
                        Color(.systemBackground)
                            .ignoresSafeArea()
                        ProgressView("Fetching latest news…")
                            .padding()
                            .tint(.primary)
                    }
                }
            }
            .alert(item: $vm.alertItem) { alertItem in
                Alert(title: Text(alertItem.title), message: Text(alertItem.message), dismissButton: .default(Text("OK")))
            }
        }
    }
 
}
