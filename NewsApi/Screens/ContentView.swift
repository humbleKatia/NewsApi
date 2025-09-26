//
//  ContentView.swift
//  NewsApi
//
//  Created by Ekaterina Lysova on 30/08/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NewsView()
                .tabItem {
                    Label("News", systemImage: "sparkles.tv")
                }
            SavedView()
                .tabItem {
                    Label("Saved", systemImage: "bookmark")
                }
        }
        .accentColor(.red)
    }
}

#Preview {
    ContentView()
}
