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
            ZStack {
                List {
                    ForEach(vm.savedArticles) { article in
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
                .navigationTitle("Saved News")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }  
}

#Preview {
    SavedView()
}
