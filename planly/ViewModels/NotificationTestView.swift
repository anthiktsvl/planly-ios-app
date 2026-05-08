//
//  NotificationTestView.swift
//  Planly
//
//  Debug view to test notifications
//

import SwiftUI
import UserNotifications

struct NotificationTestView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var isAuthorized = false
    @State private var pendingCount = 0
    @State private var deliveredCount = 0
    @State private var testMessage = ""
    
    var body: some View {
        NavigationView {
            List {
                Section("Authorization Status") {
                    HStack {
                        Text("Authorized")
                        Spacer()
                        Image(systemName: notificationManager.isAuthorized ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(notificationManager.isAuthorized ? .green : .red)
                    }
                    
                    HStack {
                        Text("Enabled")
                        Spacer()
                        Image(systemName: notificationManager.notificationsEnabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(notificationManager.notificationsEnabled ? .green : .red)
                    }
                    
                    Button("Request Permission") {
                        Task {
                            let granted = await notificationManager.requestAuthorization()
                            testMessage = granted ? "✅ Permission Granted!" : "❌ Permission Denied"
                        }
                    }
                }
                
                Section("Notification Counts") {
                    HStack {
                        Text("Pending")
                        Spacer()
                        Text("\(pendingCount)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Delivered")
                        Spacer()
                        Text("\(deliveredCount)")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Refresh Counts") {
                        Task {
                            await updateCounts()
                        }
                    }
                }
                
                Section("Test Notifications") {
                    Button("Send Test Notification (3 sec)") {
                        sendTestNotification()
                    }
                    
                    Button("Send Immediate Notification") {
                        sendImmediateNotification()
                    }
                    
                    Button("Clear All Notifications") {
                        Task {
                            await notificationManager.cancelAllNotifications()
                            notificationManager.clearBadge()
                            await updateCounts()
                            testMessage = "🗑️ All notifications cleared"
                        }
                    }
                    .foregroundColor(.red)
                }
                
                if !testMessage.isEmpty {
                    Section("Result") {
                        Text(testMessage)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Notification Test")
            .onAppear {
                Task {
                    await notificationManager.checkAuthorization()
                    await updateCounts()
                }
            }
        }
    }
    
    private func updateCounts() async {
        let pending = await notificationManager.getPendingNotifications()
        pendingCount = pending.count
        deliveredCount = await notificationManager.getBadgeCount()
    }
    
    private func sendTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "This is a test notification scheduled for 3 seconds"
        content.sound = .default
        content.badge = NSNumber(value: 1)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    testMessage = "❌ Error: \(error.localizedDescription)"
                } else {
                    testMessage = "✅ Test notification scheduled for 3 seconds!"
                }
            }
        }
    }
    
    private func sendImmediateNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Immediate Test"
        content.body = "This notification should appear in 1 second"
        content.sound = .default
        content.badge = NSNumber(value: 1)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    testMessage = "❌ Error: \(error.localizedDescription)"
                } else {
                    testMessage = "✅ Immediate notification sent!"
                }
            }
        }
    }
}

#Preview {
    NotificationTestView()
}
