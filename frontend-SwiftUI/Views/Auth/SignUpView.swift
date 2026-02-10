//
//  SignUpView.swift
//  Planly
//
//  Sign up screen
//

import SwiftUI
import Combine

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    var body: some View {
        ZStack {
            ColorTheme.offWhite
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // Logo/Header
                    VStack(spacing: 10) {
                        Image(systemName: "person.crop.circle.fill.badge.plus")
                            .font(.system(size: 80))
                            .foregroundStyle(ColorTheme.buttonGradient)
                        
                        Text("Create Account")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(ColorTheme.textPrimary)
                        
                        Text("Sign up to get started")
                            .font(.subheadline)
                            .foregroundColor(ColorTheme.textSecondary)
                    }
                    .padding(.top, 50)
                    
                    // Error Message
                    if let errorMessage = authViewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(ColorTheme.babyPinkDark)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    // Name Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(ColorTheme.textPrimary)
                        
                        TextField("Enter your name", text: $name)
                            .padding()
                            .background(ColorTheme.pureWhite)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(ColorTheme.babyPink, lineWidth: 1)
                            )
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
                    
                    // Confirm Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Confirm Password")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(ColorTheme.textPrimary)
                        
                        SecureField("Confirm your password", text: $confirmPassword)
                            .padding()
                            .background(ColorTheme.pureWhite)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(ColorTheme.babyPink, lineWidth: 1)
                            )
                        
                        if !password.isEmpty && !confirmPassword.isEmpty && password != confirmPassword {
                            Text("Passwords don't match")
                                .font(.caption)
                                .foregroundColor(.pink)
                        }
                    }
                    
                    // Sign Up Button
                    Button {
                        Task {
                            await authViewModel.signUp(name: name, email: email, password: password)
                        }
                    } label: {
                        HStack {
                            if authViewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Sign Up")
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
                    .disabled(isSignUpDisabled)
                    .opacity(isSignUpDisabled ? 0.6 : 1.0)
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .padding(.horizontal, 30)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var isSignUpDisabled: Bool {
        name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        password != confirmPassword ||
        authViewModel.isLoading
    }
}

#Preview {
    NavigationStack {
        SignUpView()
            .environmentObject(AuthViewModel())
    }
}
