import SwiftUI

struct LoginView: View {

    @Bindable var viewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {

                    // MARK: - Identidad de la Aplicación

                    VStack(spacing: 12) {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .font(.system(size: 64))
                            .foregroundStyle(.indigo)
                            .accessibilityHidden(true)

                        Text("RadioTV")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Tu espacio para escuchar y ver")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 48)

                    // MARK: - Datos de Acceso

                    VStack(alignment: .leading, spacing: 20) {
                        Text("Inicia sesión")
                            .font(.title2)
                            .fontWeight(.semibold)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Usuario")
                                .font(.subheadline)
                                .fontWeight(.medium)

                            TextField(
                                "Escribe tu usuario",
                                text: $viewModel.usuario
                            )
                            .textContentType(.username)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .textFieldStyle(.roundedBorder)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Contraseña")
                                .font(.subheadline)
                                .fontWeight(.medium)

                            SecureField(
                                "Escribe tu contraseña",
                                text: $viewModel.contrasena
                            )
                            .textContentType(.password)
                            .textFieldStyle(.roundedBorder)
                        }

                        // Mensaje de error de validación
                        if let mensaje = viewModel.mensajeError {
                            Text(mensaje)
                                .font(.subheadline)
                                .foregroundStyle(.red)
                                .accessibilityAddTraits(.isStaticText)
                        }

                        // MARK: - Botón Iniciar Sesión

                        // Solicita al ViewModel que valide el acceso.
                        Button {
                            viewModel.iniciarSesion()
                        } label: {
                            Text("Iniciar sesión")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.indigo)
                    }
                    .padding(24)
                    .background(
                        .background,
                        in: RoundedRectangle(cornerRadius: 24)
                    )
                }
                .frame(maxWidth: 440)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                .frame(maxWidth: .infinity)
            }
            .background(Color.indigo.opacity(0.06))
            .scrollDismissesKeyboard(.interactively)
        }
    }
}

// MARK: - Preview

#Preview {
    LoginView(viewModel: AuthViewModel())
}
