//
//  NewsApiApp.swift
//  NewsApi
//
//  Created by Ekaterina Lysova on 30/08/2025.
//
//
import SwiftUI
import BackgroundTasks
import CoreData



@main
struct NewsApiApp: App {
    
    @StateObject private var vm = ViewModel(repository: NewsRepository(), coreDataManager: CoreDataManager())
    
    let taskIdentifier = "com.newsapp.refresh"
    
    // Get a reference to the app's current state (active, background, etc.).
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(vm)
        }
        // This modifier watches for the app's state to change.
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background {
                // When the user sends the app to the background, schedule the next fetch.
                scheduleNewsFetch()
            }
        }
        // This is where we register our task handler.
        .backgroundTask(.appRefresh(taskIdentifier)) {
            await handleAppRefresh()
        }
    }
    
    
    
    
    func scheduleNewsFetch() {
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("🗓️ Background app refresh task scheduled.")
        } catch {
            print("❌ Could not schedule background task: \(error)")
        }
    }
    
    
    
    func handleAppRefresh() async {
        print("⚡️ Background task started...")
        scheduleNewsFetch()
        await vm.fetchLatestNews()
    }
    
    
    
    
}
