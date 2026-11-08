import Foundation

// MARK: - Validación de credenciales

struct AuthManager {

    // MARK: - Credenciales del ejercicio

    private let usuarioValido = "USUARIO"
    private let contrasenaValida = "CONTRASEÑA"

    // MARK: - Validar acceso

    func validar(usuario: String, contrasena: String) -> Bool {
        usuario == usuarioValido &&
        contrasena == contrasenaValida
    }
}
