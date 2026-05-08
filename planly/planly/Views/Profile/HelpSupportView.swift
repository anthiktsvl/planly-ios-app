import SwiftUI
import UIKit

struct HelpSupportView: View {
    @State private var showEmailFallback = false
    private let supportEmail = "anthikoutsouveli@gmail.com"

    var body: some View {
        NavigationView {
            List {
                Section("Support") {
                    Button("Email Support") {
                        let url = URL(string: "mailto:\(supportEmail)")!
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        } else {
                            UIPasteboard.general.string = supportEmail
                            showEmailFallback = true
                        }
                    }

                    Button("Copy Support Email") {
                        UIPasteboard.general.string = supportEmail
                    }
                }
            }
            .navigationTitle("Help & Support")
            .alert("Email not available", isPresented: $showEmailFallback) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("No email app is configured. I copied the support email to your clipboard:\n\(supportEmail)")
            }
        }
    }
}
