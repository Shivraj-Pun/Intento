import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    enum Step {
        case phoneEntry
        case otpEntry
    }
    
    @Published var currentStep: Step = .phoneEntry
    @Published var phoneNumber: String = ""
    @Published var name: String = ""
    @Published var otp: String = ""
    @Published var isProcessing: Bool = false
    @Published var errorMessage: String? = nil
    
    private let authService: AuthServicing
    
    var isPhoneValid: Bool {
        phoneNumber.count >= 10
    }
    
    var isOTPValid: Bool {
        otp.count >= 4
    }
    
    init(authService: AuthServicing) {
        self.authService = authService
    }
    
    func sendOTP() {
        guard isPhoneValid else { return }
        isProcessing = true
        errorMessage = nil
        
        Task {
            do {
                try await authService.sendOTP(phone: phoneNumber)
                currentStep = .otpEntry
            } catch {
                errorMessage = "Failed to send OTP. Please try again."
            }
            isProcessing = false
        }
    }
    
    func verifyOTP() {
        guard isOTPValid else { return }
        isProcessing = true
        errorMessage = nil
        
        Task {
            do {
                try await authService.verifyOTP(phone: phoneNumber, otp: otp, name: name.isEmpty ? nil : name)
                // App state will automatically update based on authService publisher
            } catch {
                errorMessage = "Invalid OTP. Please try again."
            }
            isProcessing = false
        }
    }
    
    func goBack() {
        currentStep = .phoneEntry
        otp = ""
        errorMessage = nil
    }
}
