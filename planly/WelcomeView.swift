//
//  WelcomeView.swift
//  Planly
//
//  Welcome screen with sign in/sign up options
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showSignIn = false
    @State private var showSignUp = false
    @State private var animateContent = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                ColorTheme.offWhite
                    .ignoresSafeArea()
                
                // Decorative background elements
                GeometryReader { geometry in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    ColorTheme.primary(for: themeManager.currentTheme).opacity(0.2),
                                    .clear
                                ],
                                center: .topLeading,
                                startRadius: 0,
                                endRadius: 300
                            )
                        )
                        .frame(width: 300, height: 300)
                        .offset(x: -100, y: -100)
                    
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    ColorTheme.primary(for: themeManager.currentTheme).opacity(0.15),
                                    .clear
                                ],
                                center: .bottomTrailing,
                                startRadius: 0,
                                endRadius: 250
                            )
                        )
                        .frame(width: 250, height: 250)
                        .offset(x: geometry.size.width - 100, y: geometry.size.height - 100)
                }
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Logo and app name
                    VStack(spacing: 20) {
                        Image(systemName: "calendar.badge.checkmark")
                            .font(.system(size: 100))
                            .foregroundStyle(ColorTheme.gradient(for: themeManager.currentTheme))
                            .scaleEffect(animateContent ? 1.0 : 0.8)
                            .opacity(animateContent ? 1.0 : 0.0)
                        
                        Text("planly")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(ColorTheme.dark(for: themeManager.currentTheme))
                            .opacity(animateContent ? 1.0 : 0.0)
                        
                        Text("Organize your life with ease")
                            .font(.title3)
                            .foregroundColor(ColorTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .opacity(animateContent ? 1.0 : 0.0)
                    }
                    .offset(y: animateContent ? 0 : 20)
                    
                    Spacer()
                    
                    // Action buttons
                    VStack(spacing: 16) {
                        // Sign Up Button
                        NavigationLink(destination: SignUpView()) {
                            Text("Get Started")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(ColorTheme.gradient(for: themeManager.currentTheme))
                                .cornerRadius(16)
                                .shadow(
                                    color: ColorTheme.dark(for: themeManager.currentTheme).opacity(0.3),
                                    radius: 10,
                                    x: 0,
                                    y: 5
                                )
                        }
                        .opacity(animateContent ? 1.0 : 0.0)
                        .offset(y: animateContent ? 0 : 20)
                        
                        // Sign In Button
                        NavigationLink(destination: SignInView()) {
                            Text("I Already Have an Account")
                                .fontWeight(.medium)
                                .foregroundColor(ColorTheme.dark(for: themeManager.currentTheme))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(ColorTheme.pureWhite)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(ColorTheme.primary(for: themeManager.currentTheme), lineWidth: 2)
                                )
                        }
                        .opacity(animateContent ? 1.0 : 0.0)
                        .offset(y: animateContent ? 0 : 20)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 50)
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.6)) {
                    animateContent = true
                }
            }
        }
    }
}

#Preview {
    WelcomeView()
        .environmentObject(ThemeManager())
        .environmentObject(AuthViewModel())
}
