import SwiftUI
import Combine

struct AppCoordinatorView: View {
    let container: AppContainer
    @State private var authState: AuthState = .loggedOut
    
    var body: some View {
        Group {
            switch authState {
            case .loggedIn:
                RootView(container: container)
            case .loggedOut:
                LoginView(viewModel: LoginViewModel(authService: container.auth))
            }
        }
        .onReceive(container.auth.authStatePublisher) { state in
            withAnimation {
                self.authState = state
            }
        }
        .task {
            await container.auth.checkSession()
        }
    }
}
