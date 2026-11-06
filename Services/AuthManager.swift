import Foundation

// MARK: - Validación de credenciales

struct AuthManager {

    // MARK: - Credenciales del ejercicio

    private let usuarioValido = "estudiante"
    private let contrasenaValida = "RadioTV2026"

    // MARK: - Validar acceso

    func validar(usuario: String, contrasena: String) -> Bool {
        usuario == usuarioValido &&
        contrasena == contrasenaValida
    }
}
