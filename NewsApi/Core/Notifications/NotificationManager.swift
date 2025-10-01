//
//  NotificationManager.swift
//  NewsApi
//
//  Created by Ekaterina Lysova on 10/09/2025.
//

import UIKit
import UserNotifications

struct UserNotificationManager {
    static let shared = UserNotificationManager()
    
    func requestNotificationPermission() async {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            if granted {
                print("✅ Notification permission granted.")
            } else {
                print("❌ Notification permission denied.")
            }
        } catch {
            print("❌ Notification permission error: \(error)")
        }
    }
    
    func sendNotification(title: String, message: String, imageAttachmentURL: URL? = nil) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = UNNotificationSound.default
        
        if let imageURL = imageAttachmentURL {
            do {
                let attachment = try UNNotificationAttachment(identifier: "newsImage", url: imageURL, options: nil)
                content.attachments = [attachment]
            } catch {
                print("❌ Could not create notification attachment: \(error)")
            }
        }
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to send notification: \(error)")
            } else {
                print("✅ Notification sent successfully.")
            }
        }
    }
}
