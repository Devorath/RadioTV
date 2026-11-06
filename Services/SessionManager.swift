import Foundation
import Security

// MARK: - Errores de almacenamiento

enum SessionError: LocalizedError {
    case keychain(OSStatus)
    case datosInvalidos

    var errorDescription: String? {
        switch self {
        case .keychain(let codigo):
            return "No se pudo acceder a la sesión. Código: \(codigo)."

        case .datosInvalidos:
            return "La información guardada de la sesión no es válida."
        }
    }
}

// MARK: - Almacenamiento de sesión

struct SessionManager {

    // MARK: - Identificadores de Keychain

    private let servicio = "com.devorath.RadioTV.sesion"
    private let cuenta = "sesionActiva"

    // Identifica únicamente el dato de sesión de nuestra app.
    private var consultaBase: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: servicio,
            kSecAttrAccount as String: cuenta
        ]
    }

    // MARK: - Guardar sesión

    func guardarSesion() throws {
        let datos = Data("activa".utf8)

        let cambios: [String: Any] = [
            kSecValueData as String: datos
        ]

        // Si la sesión ya existe, actualizamos su valor.
        let resultado = SecItemUpdate(
            consultaBase as CFDictionary,
            cambios as CFDictionary
        )

        if resultado == errSecItemNotFound {
            // Si aún no existe, creamos el registro.
            var nuevaSesion = consultaBase
            nuevaSesion[kSecValueData as String] = datos
            nuevaSesion[kSecAttrAccessible as String] =
                kSecAttrAccessibleWhenUnlockedThisDeviceOnly

            let resultadoAlta = SecItemAdd(
                nuevaSesion as CFDictionary,
                nil
            )

            guard resultadoAlta == errSecSuccess else {
                throw SessionError.keychain(resultadoAlta)
            }

        } else if resultado != errSecSuccess {
            throw SessionError.keychain(resultado)
        }
    }

    // MARK: - Consultar sesión

    func haySesionGuardada() throws -> Bool {
        var consulta = consultaBase
        consulta[kSecReturnData as String] = true
        consulta[kSecMatchLimit as String] = kSecMatchLimitOne

        var resultado: CFTypeRef?

        let estado = SecItemCopyMatching(
            consulta as CFDictionary,
            &resultado
        )

        // No encontrar una sesión es normal en el primer inicio.
        if estado == errSecItemNotFound {
            return false
        }

        guard estado == errSecSuccess else {
            throw SessionError.keychain(estado)
        }

        guard
            let datos = resultado as? Data,
            String(data: datos, encoding: .utf8) == "activa"
        else {
            throw SessionError.datosInvalidos
        }

        return true
    }

    // MARK: - Eliminar sesión

    func eliminarSesion() throws {
        let resultado = SecItemDelete(
            consultaBase as CFDictionary
        )

        guard
            resultado == errSecSuccess ||
            resultado == errSecItemNotFound
        else {
            throw SessionError.keychain(resultado)
        }
    }
}
