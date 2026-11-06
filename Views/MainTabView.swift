import SwiftUI

// MARK: - Navegación principal

struct MainTabView: View {

    // MARK: - ViewModel de autenticación

    let authViewModel: AuthViewModel

    // MARK: - Contenido

    var body: some View {
        TabView {
            RadioListView()
                .tabItem {
                    Label("Radio", systemImage: "radio")
                }

            TVListView()
                .tabItem {
                    Label("TV", systemImage: "tv")
                }

            pantallaCuenta
                .tabItem {
                    Label("Cuenta", systemImage: "person.crop.circle")
                }
        }
        .tint(.indigo)
    }

    // MARK: - Radio pendiente de integración

    private var pantallaRadio: some View {
        NavigationStack {
            ContentUnavailableView {
                Label("Radio por internet", systemImage: "radio")
            } description: {
                Text("En el siguiente paso conectaremos las estaciones.")
            }
            .navigationTitle("Radio")
        }
    }

    // MARK: - Cuenta y cierre de sesión

    private var pantallaCuenta: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(.indigo)
                    .accessibilityHidden(true)

                Text("Tu sesión está iniciada")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Puedes cerrar sesión en este dispositivo.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                if let mensaje = authViewModel.mensajeError {
                    Text(mensaje)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                Button("Cerrar sesión", role: .destructive) {
                    authViewModel.cerrarSesion()
                }
                .buttonStyle(.bordered)
            }
            .padding(24)
            .navigationTitle("Cuenta")
        }
    }
}
