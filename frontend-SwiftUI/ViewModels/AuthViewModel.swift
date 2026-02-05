//
//  AuthViewModel.swift
//  Planly
//

import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    
    init() {
        // Check if user is already logged in
        if UserDefaults.standard.string(forKey: "authToken") != nil {
            isAuthenticated = true
            Task {
                await loadCurrentUser()
            }
        }
    }
    
    func signUp(name: String, email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.signUp(name: name, email: email, password: password)
            
            // Convert API user to UserProfile
            currentUser = UserProfile(
                id: response.user.id,
                name: response.user.name,
                email: response.user.email
            )
            
            isAuthenticated = true
            print("✅ Sign up successful: \(response.user.name)")
        } catch {
            errorMessage = "Sign up failed: \(error.localizedDescription)"
            print("❌ Sign up error: \(error)")
        }
        
        isLoading = false
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.signIn(email: email, password: password)
            
            // Convert API user to UserProfile
            currentUser = UserProfile(
                id: response.user.id,
                name: response.user.name,
                email: response.user.email
            )
            
            isAuthenticated = true
            print("✅ Sign in successful: \(response.user.name)")
        } catch {
            errorMessage = "Sign in failed: \(error.localizedDescription)"
            print("❌ Sign in error: \(error)")
        }
        
        isLoading = false
    }
    
    func signOut() {
        apiService.signOut()
        isAuthenticated = false
        currentUser = nil
        print("✅ Signed out")
    }
    
    private func loadCurrentUser() async {
        do {
            let apiUser = try await apiService.getCurrentUser()
            currentUser = UserProfile(
                id: apiUser.id,
                name: apiUser.name,
                email: apiUser.email
            )
            print("✅ Loaded current user: \(apiUser.name)")
        } catch {
            print("❌ Failed to load current user: \(error)")
            // If loading fails, sign out
            signOut()
        }
    }
}
