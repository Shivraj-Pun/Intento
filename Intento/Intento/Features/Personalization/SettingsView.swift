import SwiftUI

struct SettingsView: View {
    let config: AppConfig
    let authService: AuthServicing

    @State private var vm: PersonalizationViewModel
    @State private var currentUser: AppUser?
    @State private var showPhoneLengthAlert = false

    init(viewModel: PersonalizationViewModel, config: AppConfig, authService: AuthServicing) {
        _vm = State(initialValue: viewModel)
        self.config = config
        self.authService = authService
    }

    var body: some View {
        Form {
            if let user = currentUser {
                Section("Profile") {
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(AppColor.Semantic.brandStrong)
                            .frame(width: 24)
                        TextField("Name", text: Binding(
                            get: { user.name ?? "" },
                            set: { user.name = $0 }
                        ))
                        .textContentType(.name)
                    }

                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(AppColor.Semantic.brandStrong)
                            .frame(width: 24)
                        TextField("Phone", text: Binding(
                            get: { user.phone },
                            set: { 
                                let filtered = $0.filter { char in char.isNumber }
                                if filtered.count > 10 {
                                    showPhoneLengthAlert = true
                                }
                                user.phone = String(filtered.prefix(10)) 
                            }
                        ))
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                    }
                }
            }

            Section("Food Preferences") {
                ForEach(DietaryConstraint.allCases) { constraint in
                    Toggle(isOn: Binding(
                        get: { vm.preference.dietaryConstraints.contains(constraint) },
                        set: { _ in vm.toggleDietaryConstraint(constraint) }
                    )) {
                        Text(constraint.displayName)
                    }
                }
            }
            


            Section {
                Button(role: .destructive) {
                    Task {
                        try? await authService.logout()
                    }
                } label: {
                    Text("Logout")
                }
                
                Button(role: .destructive) {
                    Task {
                        try? await authService.deleteAccount()
                    }
                } label: {
                    Text("Delete Account")
                }
            }
        }
        .alert("Invalid Length", isPresented: $showPhoneLengthAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Phone number cannot exceed 10 digits.")
        }
        .navigationTitle("You")
        .navigationBarTitleDisplayMode(.inline)
        .task { await vm.load() }
        .onReceive(authService.authStatePublisher) { state in
            if case .loggedIn(let user) = state {
                self.currentUser = user
            } else {
                self.currentUser = nil
            }
        }
        .task {
            await authService.checkSession()
        }
    }
}
