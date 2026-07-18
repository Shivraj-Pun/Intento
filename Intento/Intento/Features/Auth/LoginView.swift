import SwiftUI

struct LoginView: View {
    @StateObject private var vm: LoginViewModel
    
    init(viewModel: LoginViewModel) {
        _vm = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                Image(systemName: "basket.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundStyle(AppColor.Semantic.brandStrong)
                    .padding(.bottom, 16)
                
                Text("Welcome to Intento")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(AppColor.Semantic.textPrimary)
                
                if vm.currentStep == .phoneEntry {
                    phoneEntryView
                } else {
                    otpEntryView
                }
                
                if let error = vm.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.caption)
                        .padding(.top, 8)
                }
                
                Spacer()
            }
            .padding(24)
            .background(AppColor.Semantic.background.ignoresSafeArea())
        }
    }
    
    private var phoneEntryView: some View {
        VStack(spacing: 16) {
            Text("Enter your phone number to get started")
                .font(.subheadline)
                .foregroundStyle(AppColor.Semantic.textSecondary)
                .multilineTextAlignment(.center)
            
            TextField("Name (Optional)", text: $vm.name)
                .textContentType(.name)
                .padding()
                .background(AppColor.Semantic.surface)
                .cornerRadius(12)
            
            TextField("Phone Number", text: $vm.phoneNumber)
                .keyboardType(.phonePad)
                .textContentType(.telephoneNumber)
                .padding()
                .background(AppColor.Semantic.surface)
                .cornerRadius(12)
            
            Button(action: {
                vm.sendOTP()
            }) {
                HStack {
                    if vm.isProcessing {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Continue")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(vm.isPhoneValid ? AppColor.Semantic.brandStrong : AppColor.Semantic.surfaceMuted)
                .foregroundStyle(vm.isPhoneValid ? .white : AppColor.Semantic.textTertiary)
                .cornerRadius(12)
            }
            .disabled(!vm.isPhoneValid || vm.isProcessing)
        }
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
    }
    
    private var otpEntryView: some View {
        VStack(spacing: 16) {
            Text("Enter the 6-digit code sent to \(vm.phoneNumber)")
                .font(.subheadline)
                .foregroundStyle(AppColor.Semantic.textSecondary)
                .multilineTextAlignment(.center)
            
            TextField("000000", text: $vm.otp)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .font(.title)
                .multilineTextAlignment(.center)
                .padding()
                .background(AppColor.Semantic.surface)
                .cornerRadius(12)
            
            Button(action: {
                vm.verifyOTP()
            }) {
                HStack {
                    if vm.isProcessing {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Verify & Login")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(vm.isOTPValid ? AppColor.Semantic.brandStrong : AppColor.Semantic.surfaceMuted)
                .foregroundStyle(vm.isOTPValid ? .white : AppColor.Semantic.textTertiary)
                .cornerRadius(12)
            }
            .disabled(!vm.isOTPValid || vm.isProcessing)
            
            Button("Change Phone Number") {
                withAnimation {
                    vm.goBack()
                }
            }
            .foregroundStyle(AppColor.Semantic.brandStrong)
            .padding(.top, 8)
        }
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
    }
}
