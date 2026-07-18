import Foundation
import Combine

enum AuthState {
    case loggedOut
    case loggedIn(AppUser)
}

protocol AuthServicing: Sendable {
    var authStatePublisher: AnyPublisher<AuthState, Never> { get }
    
    func sendOTP(phone: String) async throws
    func verifyOTP(phone: String, otp: String, name: String?) async throws
    func logout() async throws
    func deleteAccount() async throws
    func checkSession() async
}
