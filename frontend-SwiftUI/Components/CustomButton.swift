
//  CustomButton.swift
//  Planly
/* Reusable primary button used across the app. Centralizes the “Planly look” (gradient + rounded corners + shadow) so we don’t repeat styling in every screen. Also supports a simple loading state to prevent double taps while an async action is running.
*/


import SwiftUI

struct CustomButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    /* Loading state: user gets immediate feedback and we avoid layout jumps by keeping the same container.*/
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
            }
            .foregroundColor(ColorTheme.textOnPink)
            .frame(maxWidth: .infinity)
            .padding()
            .background(ColorTheme.buttonGradient)
            .cornerRadius(15)
            .shadow(color: ColorTheme.babyPinkDark.opacity(0.4), radius: 8, x: 0, y: 4)
        }
        .disabled(isLoading)
    }
}

#Preview {
    VStack(spacing: 20) {
        CustomButton(title: "Sign In") {}
        CustomButton(title: "Loading...", action: {}, isLoading: true)
    }
    .padding()
}
