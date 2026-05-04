//
//  LottieSplashView.swift
//  Planly
//
//  Lottie animated splash screen
//

import SwiftUI
import Lottie

struct LottieSplashView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var dataViewModel = AppDataViewModel()
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var fontManager = FontManager()
    @State private var isPresented = true
    
    var body: some View {
        ZStack {
            // Main app (always loaded with environment objects)
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(dataViewModel)
                .environmentObject(themeManager)
                .environmentObject(fontManager)
            
            // Splash overlay
            if isPresented {
                ZStack {
                    LinearGradient(
                        colors: [ColorTheme.light(for: themeManager.currentTheme), ColorTheme.primary(for: themeManager.currentTheme)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                        .ignoresSafeArea()
                    
                    // Centered content - Text on top, Animation below
                    VStack(spacing: 0) {
                        Spacer()
                        
                        VStack(spacing: 40) {
                            // App name and tagline ON TOP
                            VStack(spacing: 12) {
                                Text("Planly")
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .foregroundColor(.black)
                                
                                Text("Your beautiful planning companion")
                                    .font(.subheadline)
                                    .foregroundColor(.black.opacity(0.9))
                            }
                            
                            // Lottie Animation BELOW - Bigger size
                            SimpleLottieView()
                                .frame(width: 250, height: 250)
                                .clipped()
                        }
                        
                        Spacer()
                    }
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .onAppear {
            print("Splash screen appeared")
            
            // Hide splash after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                print("✅ Transitioning to main app")
                withAnimation(.easeOut(duration: 0.8)) {
                    isPresented = false
                }
            }
        }
    }
}

// MARK: - Simple Lottie View
struct SimpleLottieView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        // Container view with fixed size
        let containerView = UIView()
        containerView.backgroundColor = .clear
        
        // Lottie animation view
        let animationView = LottieAnimationView(name: "hello")
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.backgroundBehavior = .pauseAndRestore
        
        // Add animation to container
        animationView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(animationView)
        
        // Constrain animation to container bounds
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: containerView.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            animationView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        animationView.play()
        print("Animation started with constrained size")
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

#Preview {
    LottieSplashView()
}
