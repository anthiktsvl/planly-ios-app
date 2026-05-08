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
            
            
            currentUser = UserProfile(
                id: response.user.id,
                name: response.user.name,
                email: response.user.email,
                workStartTime: response.user.workStartTime,
                workEndTime: response.user.workEndTime,
                timezone: response.user.timezone,
                notificationsEnabled: response.user.notificationsEnabled
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
            
            currentUser = UserProfile(
                id: response.user.id,
                name: response.user.name,
                email: response.user.email,
                workStartTime: response.user.workStartTime,
                workEndTime: response.user.workEndTime,
                timezone: response.user.timezone,
                notificationsEnabled: response.user.notificationsEnabled
            )
            isAuthenticated = true
            print("✅ Sign in successful: \(response.user.name)")
        } catch {
            errorMessage = "Sign in failed: \(error.localizedDescription)"
            print("❌ Sign in error: \(error)")
        }
        
        isLoading = false
    }
    
    func updateProfile(
        name: String,
        workStartTime: String?,
        workEndTime: String?,
        timezone: String?,
        notificationsEnabled: Bool?
    ) async {
        isLoading = true
        errorMessage = nil

        do {
            let apiUser = try await apiService.updateProfile(
                name: name,
                workStartTime: workStartTime,
                workEndTime: workEndTime,
                timezone: timezone,
                notificationsEnabled: notificationsEnabled
            )

            currentUser = UserProfile(
                id: apiUser.id,
                name: apiUser.name,
                email: apiUser.email,
                workStartTime: apiUser.workStartTime,
                workEndTime: apiUser.workEndTime,
                timezone: apiUser.timezone,
                notificationsEnabled: apiUser.notificationsEnabled
            )
        } catch {
            errorMessage = "Update profile failed: \(error.localizedDescription)"
            print("❌ Update profile error: \(error)")
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
                email: apiUser.email,
                workStartTime: apiUser.workStartTime,
                workEndTime: apiUser.workEndTime,
                timezone: apiUser.timezone,
                notificationsEnabled: apiUser.notificationsEnabled
            )
            print("✅ Loaded current user: \(apiUser.name)")
        } catch {
            print("❌ Failed to load current user: \(error)")
            // If loading fails, sign out
            signOut()
        }
    }
}
