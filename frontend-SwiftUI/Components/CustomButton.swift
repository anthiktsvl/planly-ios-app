//
//  CustomButton.swift
//  Planly
//
//  Custom styled button with gradient
//

import SwiftUI

struct CustomButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
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
