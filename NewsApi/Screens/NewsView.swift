//
//  NewsView.swift
//  NewsApi
//
//  Created by Ekaterina Lysova on 30/08/2025.
//


import SwiftUI


struct NewsView: View {
    
    @EnvironmentObject var vm: ViewModel
    @State var articleSelected = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    ForEach(vm.articles) { article in
                        Link(destination: URL(string: article.url)!) {
                            VStack(alignment: .leading, spacing: 12) {
                                if let data = article.imageData,
                                   let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 200)
                                        .clipped()
                                        .cornerRadius(8)
                                        .overlay(
                                            Group {
                                                Button {
                                                    Task {
                                                        if vm.savedArticles.contains(where: { $0.url == article.url }) {
                                                            await vm.removeArticle(article)
                                                        } else {
                                                            await vm.addArticle(article)
                                                        }
                                                        print("\(vm.savedArticles.count)")
                                                    }
                                                } label: {
                                                    vm.savedArticles.contains(where: { $0.url == article.url }) ?
                                                    HeartButton(isSelected: true) :
                                                    HeartButton(isSelected: false)
                                                }
                                                .padding()
                                            },
                                            alignment: .topTrailing
                                        )
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
                                Text(article.title)
                                    .font(.headline)
                                    .lineLimit(3)
                            }
                            .padding(.bottom, 8)
                        }
                    }
                    .listRowInsets(.init(top: 0, leading: 10, bottom: 0, trailing: 10))
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .navigationTitle("Latest News")
                .navigationBarTitleDisplayMode(.inline)
                .task {
                    if vm.articles.isEmpty {
                        print("Core Data is empty. Fetching initial news...")
                        await vm.fetchLatestNews()
                    }
                    await UserNotificationManager.shared.requestNotificationPermission()
                }
                .refreshable {
                    await vm.fetchLatestNews()
                }
                if vm.isLoading {
                    ZStack {
                        Color.black.opacity(0.3).ignoresSafeArea()
                        ProgressView("Fetching latest news…")
                            .padding()
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
    }
    
    
    
}

#Preview {
    NewsView()
}






struct HeartButton: View {
    var isSelected: Bool
    var body: some View {
        ZStack {
            Circle()
                .frame(width: 30, height: 30)
                .foregroundColor(.white)
                .opacity(0.6)
            if isSelected {
                Image(systemName: "heart.fill")
                    .imageScale(.small)
                    .frame(width: 44, height: 44)
                    .foregroundColor(.red)
            } else {
                Image(systemName: "heart")
                    .imageScale(.small)
                    .frame(width: 44, height: 44)
                    .foregroundColor(.black)
            }
        }
    }
}
