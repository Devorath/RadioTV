import Foundation

// MARK: - Errores de radio

enum RadioError: LocalizedError {
    case claveNoConfigurada
    case respuestaInvalida
    case codigoHTTP(Int)
    case solicitudRechazada

    var errorDescription: String? {
        switch self {
        case .claveNoConfigurada:
            return "Configura tu clave de RapidAPI en APIConfig.swift."

        case .respuestaInvalida:
            return "El servidor no devolvió una respuesta válida."

        case .codigoHTTP(let codigo):
            switch codigo {
            case 401, 403:
                return """
                Revisa tu clave y la suscripción a 50K Radio Stations.
                """

            case 429:
                return """
                Se alcanzó el límite de solicitudes. Intenta más tarde.
                """

            default:
                return "No se pudo descargar la radio. Código: \(codigo)."
            }

        case .solicitudRechazada:
            return "La API no pudo completar la solicitud."
        }
    }
}

// MARK: - Descarga de estaciones

struct RadioManager {

    // MARK: - Fuente de datos

    private let estacionesURL = URL(
        string: "https://50k-radio-stations.p.rapidapi.com/radios/random?limit=20"
    )!

    // MARK: - Obtener estaciones

    func obtenerEstaciones() async throws -> [RadioStation] {
        let clave = APIConfig.rapidAPIKey.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !clave.isEmpty, clave != "COLOCA_AQUI_TU_CLAVE" else {
            throw RadioError.claveNoConfigurada
        }

        var solicitud = URLRequest(url: estacionesURL)
        solicitud.httpMethod = "GET"
        solicitud.timeoutInterval = 30

        solicitud.setValue(
            APIConfig.radioHost,
            forHTTPHeaderField: "x-rapidapi-host"
        )

        solicitud.setValue(
            clave,
            forHTTPHeaderField: "x-rapidapi-key"
        )

        let (datos, respuesta) = try await URLSession.shared.data(
            for: solicitud
        )

        guard let respuestaHTTP = respuesta as? HTTPURLResponse else {
            throw RadioError.respuestaInvalida
        }

        guard (200...299).contains(respuestaHTTP.statusCode) else {
            throw RadioError.codigoHTTP(respuestaHTTP.statusCode)
        }

        let resultado = try JSONDecoder().decode(
            RadioResponse.self,
            from: datos
        )

        guard resultado.success else {
            throw RadioError.solicitudRechazada
        }

        return resultado.data
    }
}
