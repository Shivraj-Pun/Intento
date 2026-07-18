import Foundation
import SwiftData
import Combine

enum AuthError: Error {
    case invalidOTP
    case userNotFound
    case underlying(Error)
}

final class MockSwiftDataAuthService: AuthServicing {
    private let modelContext: ModelContext
    private let authStateSubject = CurrentValueSubject<AuthState, Never>(.loggedOut)
    
    var authStatePublisher: AnyPublisher<AuthState, Never> {
        authStateSubject.eraseToAnyPublisher()
    }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func sendOTP(phone: String) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
    
    private let sessionKey = "mock_auth_user_id"

    func verifyOTP(phone: String, otp: String, name: String?) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // In this mock, we accept any OTP. In a real app, this would verify against Supabase.
        guard !otp.isEmpty else {
            throw AuthError.invalidOTP
        }
        
        // Fetch or create user
        let descriptor = FetchDescriptor<AppUser>(predicate: #Predicate { $0.phone == phone })
        let users = try modelContext.fetch(descriptor)
        
        let user: AppUser
        if let existing = users.first {
            user = existing
            if let name = name, !name.isEmpty {
                user.name = name
            }
        } else {
            user = AppUser(phone: phone, name: name)
            modelContext.insert(user)
        }
        
        try modelContext.save()
        
        UserDefaults.standard.set(user.id.uuidString, forKey: sessionKey)
        // Update state
        authStateSubject.send(.loggedIn(user))
    }
    
    func logout() async throws {
        UserDefaults.standard.removeObject(forKey: sessionKey)
        authStateSubject.send(.loggedOut)
    }
    
    func deleteAccount() async throws {
        guard case .loggedIn(let user) = authStateSubject.value else { return }
        
        modelContext.delete(user)
        try? modelContext.save()
        
        UserDefaults.standard.removeObject(forKey: sessionKey)
        authStateSubject.send(.loggedOut)
    }
    
    func checkSession() async {
        guard let userIdString = UserDefaults.standard.string(forKey: sessionKey),
              let userId = UUID(uuidString: userIdString) else {
            authStateSubject.send(.loggedOut)
            return
        }
        
        let descriptor = FetchDescriptor<AppUser>(predicate: #Predicate { $0.id == userId })
        do {
            if let user = try modelContext.fetch(descriptor).first {
                authStateSubject.send(.loggedIn(user))
            } else {
                UserDefaults.standard.removeObject(forKey: sessionKey)
                authStateSubject.send(.loggedOut)
            }
        } catch {
            authStateSubject.send(.loggedOut)
        }
    }
}
