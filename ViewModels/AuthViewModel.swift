import Foundation
import Observation

// MARK: - Comportamiento de autenticación

@MainActor
@Observable
final class AuthViewModel {

    // MARK: - Datos del formulario

    var usuario = ""
    var contrasena = ""

    // MARK: - Estado de la pantalla

    private(set) var sesionIniciada = false
    private(set) var mensajeError: String?

    // MARK: - Managers

    private let authManager = AuthManager()
    private let sessionManager = SessionManager()

    // MARK: - Inicialización

    init() {
        recuperarSesion()
    }

    // MARK: - Recuperar sesión guardada

    private func recuperarSesion() {
        do {
            sesionIniciada = try sessionManager.haySesionGuardada()
        } catch {
            sesionIniciada = false
            mensajeError = """
            No pudimos recuperar tu sesión. Intenta iniciar sesión nuevamente.
            """
        }
    }

    // MARK: - Iniciar sesión

    func iniciarSesion() {
        mensajeError = nil

        let usuarioLimpio = usuario.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !usuarioLimpio.isEmpty, !contrasena.isEmpty else {
            mensajeError = "Escribe tu usuario y contraseña."
            return
        }

        guard authManager.validar(
            usuario: usuarioLimpio,
            contrasena: contrasena
        ) else {
            mensajeError = "El usuario o la contraseña son incorrectos."
            return
        }

        do {
            // Entramos únicamente si se pudo guardar la sesión.
            try sessionManager.guardarSesion()

            contrasena = ""
            sesionIniciada = true

        } catch {
            mensajeError = """
            No pudimos guardar tu sesión. Intenta nuevamente.
            """
        }
    }

    // MARK: - Cerrar sesión

    func cerrarSesion() {
        mensajeError = nil

        do {
            try sessionManager.eliminarSesion()

            sesionIniciada = false
            usuario = ""
            contrasena = ""

        } catch {
            mensajeError = """
            No pudimos cerrar tu sesión. Intenta nuevamente.
            """
        }
    }
}
