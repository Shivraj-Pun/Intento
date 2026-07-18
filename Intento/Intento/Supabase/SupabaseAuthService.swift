import Foundation
import Combine
import Supabase

/// Supabase-backed authentication service using Phone OTP.
/// Conforms to the existing `AuthServicing` protocol for drop-in replacement.
final class SupabaseAuthService: AuthServicing {
    private let client: SupabaseClient
    private let authStateSubject = CurrentValueSubject<AuthState, Never>(.loggedOut)
    
    /// In-memory cache of the current user profile to avoid redundant DB calls.
    private var cachedUser: AppUser?
    
    var authStatePublisher: AnyPublisher<AuthState, Never> {
        authStateSubject.eraseToAnyPublisher()
    }
    
    init(client: SupabaseClient = SupabaseManager.client) {
        self.client = client
    }
    
    // MARK: - AuthServicing
    
    func sendOTP(phone: String) async throws {
        // Format phone to E.164 for Supabase (+91 prefix for India)
        let formattedPhone = formatPhone(phone)
        try await client.auth.signInWithOTP(phone: formattedPhone)
    }
    
    func verifyOTP(phone: String, otp: String, name: String?) async throws {
        let formattedPhone = formatPhone(phone)
        
        try await client.auth.verifyOTP(
            phone: formattedPhone,
            token: otp,
            type: .sms
        )
        
        // After successful verification, update user name if provided
        if let name = name, !name.isEmpty {
            _ = try? await client.auth.update(user: UserAttributes(data: ["name": .string(name)]))
        }
        
        // Fetch user profile from our app_users table (created by the trigger)
        try await fetchAndCacheUser()
    }
    
    func logout() async throws {
        try await client.auth.signOut()
        cachedUser = nil
        authStateSubject.send(.loggedOut)
    }
    
    func deleteAccount() async throws {
        // Sign out locally (full server-side user deletion requires admin key via Edge Function)
        try await client.auth.signOut()
        cachedUser = nil
        authStateSubject.send(.loggedOut)
    }
    
    func checkSession() async {
        do {
            // The Supabase SDK persists sessions to Keychain automatically.
            // This call reads from Keychain — no network request.
            _ = try await client.auth.session
            
            // We have a valid session. Fetch user data only if not already cached.
            if cachedUser == nil {
                try await fetchAndCacheUser()
            } else if let user = cachedUser {
                authStateSubject.send(.loggedIn(user))
            }
        } catch {
            // No valid session found
            cachedUser = nil
            authStateSubject.send(.loggedOut)
        }
    }
    
    // MARK: - Private Helpers
    
    /// Fetches the user profile from `app_users` and caches it in-memory.
    /// This is called exactly once per session (after login or session restore).
    private func fetchAndCacheUser() async throws {
        let session = try await client.auth.session
        let userId = session.user.id
        
        // Query our app_users table for this user's profile
        struct AppUserRow: Decodable {
            let id: UUID
            let phone: String
            let name: String?
        }
        
        let rows: [AppUserRow] = try await client.from("app_users")
            .select()
            .eq("id", value: userId.uuidString)
            .execute()
            .value
        
        if let row = rows.first {
            let appUser = AppUser(id: row.id, phone: row.phone, name: row.name)
            cachedUser = appUser
            authStateSubject.send(.loggedIn(appUser))
        } else {
            // User might not be created by trigger yet (race condition).
            // Use auth metadata as fallback.
            let user = session.user
            let phone = user.phone ?? ""
            let name: String? = {
                if case let .string(n) = user.userMetadata["name"] {
                    return n
                }
                return nil
            }()
            let cleanPhone = phone.replacingOccurrences(of: "+91", with: "")
            let appUser = AppUser(id: userId, phone: cleanPhone, name: name)
            cachedUser = appUser
            authStateSubject.send(.loggedIn(appUser))
        }
    }
    
    /// Formats a 10-digit phone number to E.164 format for Supabase.
    private func formatPhone(_ phone: String) -> String {
        let digits = phone.filter { $0.isNumber }
        if digits.hasPrefix("91") && digits.count == 12 {
            return "+\(digits)"
        }
        return "+91\(digits)"
    }
}
