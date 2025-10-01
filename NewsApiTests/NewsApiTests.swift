//
//  NewsApiTests.swift
//  NewsApiTests
//
//  Created by Ekaterina Lysova on 30/08/2025.
//

import Testing
@testable import NewsApi

@MainActor
struct NewsApiTests {
    
    private func makeSampleArticle(id: String) -> Article {
        return Article(source: Source(id: nil, name: "Test Source"),
                       author: "author",
                       title: "Test title \(id)",
                       description: "Test Description",
                       url: "https://example.com/\(id)",
                       urlToImage: nil,
                       publishedAt: nil,
                       content: nil)
    }

    @Test func testAddArticle_ShouldUpdateSavedArticles() async throws {
       let mockRepo = MockNewsRepository()
        let mockDB = MockDBManager()
        let articleToAdd = makeSampleArticle(id: "1")
        
        let viewModel = ViewModel(repository: mockRepo, coreDataManager: mockDB)
        
        await viewModel.addArticle(articleToAdd)
        
        #expect(viewModel.savedArticles.count == 1)
        #expect(viewModel.savedArticles.first?.url == "https://example.com/1")
        #expect(viewModel.savedArticleURLs.contains("https://example.com/1"))
        #expect(mockDB.saveArticleToSavedViewCalled == true)
    }
    
    @Test func testRemoveArticle_ShouldUpdateSavedArticles() async throws {
        let mockRepo = MockNewsRepository()
        let mockDB = MockDBManager()
        let article = makeSampleArticle(id: "1")
        
        let viewModel = ViewModel(repository: mockRepo, coreDataManager: mockDB)
        await viewModel.addArticle(article)
        
        #expect(viewModel.savedArticles.count == 1)
        
        await viewModel.removeArticle(article)
        
        #expect(viewModel.savedArticles.isEmpty)
        #expect(viewModel.savedArticleURLs.isEmpty)
        #expect(mockDB.deleteSavedArticleCalled == true)
    }
    
    @Test func testFetchLatestNews_Success_ShouldUpdateArticles() async throws {
        let mockRepo = MockNewsRepository()
        let mockDB = MockDBManager()
        
        let networkArticles = [makeSampleArticle(id: "net1"), makeSampleArticle(id: "net2")]
        mockRepo.articlesToReturn = networkArticles
        
        let viewModel = ViewModel(repository: mockRepo, coreDataManager: mockDB)
        
        await viewModel.fetchLatestNews()
        
        #expect(viewModel.isLoading == false)
        #expect(viewModel.articles.count == 2)
        #expect(viewModel.articles.first?.url == "https://example.com/net1")
        #expect(mockDB.saveArticlesCalled == true)
    }
    
    @Test func testFetchLatestNews_Failure_ShouldSetAlertItem() async throws {
       
          let mockRepo = MockNewsRepository()
          let mockDB = MockDBManager()
     
          mockRepo.errorToThrow = NewsError.invalidServerResponse
          
          let viewModel = ViewModel(repository: mockRepo, coreDataManager: mockDB)

          await viewModel.fetchLatestNews()
      
          #expect(viewModel.isLoading == false)
          #expect(viewModel.articles.isEmpty)
          #expect(viewModel.alertItem != nil)
          #expect(viewModel.alertItem?.title == "Failed to Fetch News")
      }

}
