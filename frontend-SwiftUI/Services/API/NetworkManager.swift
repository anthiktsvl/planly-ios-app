//
//  NetworkManager.swift
//  Planly
//
//  Network Request Manager
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    // MARK: - Generic Request
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get,
        body: Data? = nil,
        requiresAuth: Bool = false
    ) async throws -> T {
        
        guard let url = URL(string: APIConfig.baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add auth token if required
        if requiresAuth {
            if let token = UserDefaults.standard.string(forKey: "authToken") {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            } else {
                throw APIError.unauthorized
            }
        }
        
        // Add body if present
        if let body = body {
            request.httpBody = body
        }
        
        // Print request for debugging
        print("📤 \(method.rawValue) \(url.absoluteString)")
        if let body = body, let jsonString = String(data: body, encoding: .utf8) {
            print("📦 Body: \(jsonString)")
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            print("📥 Response: \(httpResponse.statusCode)")
            
            // Print response for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 Response Body: \(jsonString)")
            }
            
            // Handle HTTP errors
            guard (200...299).contains(httpResponse.statusCode) else {
                // Try to parse error message
                let simpleDecoder = JSONDecoder()
                if let errorResponse = try? simpleDecoder.decode(ErrorResponse.self, from: data) {
                    throw APIError.httpError(httpResponse.statusCode, errorResponse.error)
                }
                throw APIError.httpError(httpResponse.statusCode, nil)
            }
            
            // Decode response - Simple approach without strategies
            do {
                let decoder = JSONDecoder()
                let decoded = try decoder.decode(T.self, from: data)
                return decoded
            } catch {
                throw APIError.decodingError(error)
            }
            
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    // MARK: - Request without response body
    func request(
        endpoint: String,
        method: HTTPMethod = .get,
        body: Data? = nil,
        requiresAuth: Bool = false
    ) async throws {
        
        guard let url = URL(string: APIConfig.baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if requiresAuth {
            if let token = UserDefaults.standard.string(forKey: "authToken") {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            } else {
                throw APIError.unauthorized
            }
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        print("📤 \(method.rawValue) \(url.absoluteString)")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        print("📥 Response: \(httpResponse.statusCode)")
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(httpResponse.statusCode, nil)
        }
    }
}

// MARK: - HTTP Method
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

// MARK: - Error Response
struct ErrorResponse: Codable {
    let error: String
}
