//
//  SignInView.swift
//  Planly
//
//  Sign in screen
//

import SwiftUI
import Combine

struct SignInView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
       @State private var email = ""
       @State private var password = ""
    
    var body: some View {
        ZStack {
            ColorTheme.offWhite
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // Logo/Header
                    VStack(spacing: 10) {
                        Image(systemName: "calendar.badge.checkmark")
                            .font(.system(size: 80))
                            .foregroundStyle(ColorTheme.buttonGradient)
                        
                        Text("Welcome Back!")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(ColorTheme.textPrimary)
                        
                        Text("Sign in to continue")
                            .font(.subheadline)
                            .foregroundColor(ColorTheme.textSecondary)
                    }
                    .padding(.top, 50)
                    
                    // Error Message
                    if let errorMessage = authViewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    // Email Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(ColorTheme.textPrimary)
                        
                        TextField("Enter your email", text: $email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .padding()
                            .background(ColorTheme.pureWhite)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(ColorTheme.babyPink, lineWidth: 1)
                            )
                    }
                    
                    // Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(ColorTheme.textPrimary)
                        
                        SecureField("Enter your password", text: $password)
                            .padding()
                            .background(ColorTheme.pureWhite)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(ColorTheme.babyPink, lineWidth: 1)
                            )
                    }
                    
                    // Sign In Button
                    Button {
                        Task {
                            await authViewModel.signIn(email: email, password: password)
                        }
                    } label: {
                        HStack {
                            if authViewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Sign In")
                                    .fontWeight(.semibold)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(ColorTheme.buttonGradient)
                        .cornerRadius(12)
                        .shadow(color: ColorTheme.babyPinkDark.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .disabled(email.isEmpty || password.isEmpty || authViewModel.isLoading)
                    .opacity((email.isEmpty || password.isEmpty || authViewModel.isLoading) ? 0.6 : 1.0)
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .padding(.horizontal, 30)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SignInView()
            .environmentObject(AuthViewModel())
    }
}
