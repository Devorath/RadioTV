import SwiftUI

// MARK: - Pantalla raíz

struct ContentView: View {

    // MARK: - ViewModel de autenticación

    @State private var viewModel = AuthViewModel()

    // MARK: - Contenido

    var body: some View {
        Group {
            if viewModel.sesionIniciada {
                MainTabView(authViewModel: viewModel)
            } else {
                LoginView(viewModel: viewModel)
            }
        }
    }
}

// MARK: - Vista previa

#Preview {
    ContentView()
}
