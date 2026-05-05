//
//  WelcomeView.swift
//  Planly
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                ColorTheme.offWhite
                    .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Logo
                    VStack(spacing: 20) {
                        Image(systemName: "calendar.badge.checkmark")
                            .font(.system(size: 100))
                            .foregroundStyle(ColorTheme.buttonGradient)
                        
                        Text("Planly")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundStyle(ColorTheme.buttonGradient)
                        
                        Text("Your personal productivity companion")
                            .font(.subheadline)
                            .foregroundColor(ColorTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    
                    Spacer()
                    
                    // Buttons
                    VStack(spacing: 16) {
                        NavigationLink {
                            SignUpView()
                        } label: {
                            Text("Get Started")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(ColorTheme.buttonGradient)
                                .cornerRadius(12)
                                .shadow(color: ColorTheme.babyPinkDark.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        
                        NavigationLink {
                            SignInView()
                        } label: {
                            Text("Sign In")
                                .fontWeight(.semibold)
                                .foregroundColor(ColorTheme.babyPinkDark)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(ColorTheme.pureWhite)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(ColorTheme.babyPink, lineWidth: 2)
                                )
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 50)
                }
            }
        }
    }
}

#Preview {
    WelcomeView()
}
