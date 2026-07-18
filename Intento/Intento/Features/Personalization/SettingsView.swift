import SwiftUI

struct SettingsView: View {
    let config: AppConfig
    let authService: AuthServicing

    @State private var vm: PersonalizationViewModel
    @State private var currentUser: AppUser?

    init(viewModel: PersonalizationViewModel, config: AppConfig, authService: AuthServicing) {
        _vm = State(initialValue: viewModel)
        self.config = config
        self.authService = authService
    }

    var body: some View {
        Form {
            if let user = currentUser {
                Section("Profile") {
                    TextField("Name", text: Binding(
                        get: { user.name ?? "" },
                        set: { user.name = $0 }
                    ))
                    .textContentType(.name)

                    TextField("Phone", text: Binding(
                        get: { user.phone },
                        set: { user.phone = $0 }
                    ))
                    .textContentType(.telephoneNumber)
                    .keyboardType(.phonePad)
                    .disabled(true) // Phone is usually tied to auth
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
            
            Section("Preferences") {
                Toggle(isOn: Binding(get: { vm.preference.nutritionAwareEnabled }, set: { vm.setNutritionAware($0) })) {
                    Label("Healthier swaps by default", systemImage: "heart.text.square")
                }
                Toggle(isOn: Binding(get: { vm.preference.sustainabilityNudgesEnabled }, set: { vm.setSustainabilityNudges($0) })) {
                    Label("Sustainability nudges", systemImage: "leaf")
                }
                Stepper(value: Binding(get: { vm.preference.defaultPeopleCount ?? 2 }, set: { vm.setDefaultPeople($0) }), in: 1...20) {
                    Label("Default people: \(vm.preference.defaultPeopleCount ?? 2)", systemImage: "person.2")
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
