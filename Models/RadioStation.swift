import Foundation

// MARK: - Respuesta de la API

struct RadioResponse: Decodable {
    let success: Bool
    let data: [RadioStation]
}

// MARK: - Estación de radio

struct RadioStation: Decodable, Identifiable {
    let id: Int
    let name: String
    let genre: RadioGenre?
    let location: RadioLocation?
    let streams: [RadioStream]?

    // MARK: - Datos para mostrar

    var genero: String {
        let texto = genre?.text?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return texto.flatMap { $0.isEmpty ? nil : $0 }
            ?? "Género no disponible"
    }

    var pais: String {
        let texto = location?.countryName?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return texto.flatMap { $0.isEmpty ? nil : $0 }
            ?? "País no disponible"
    }

    // MARK: - Selección de transmisión

    var streamURL: URL? {
        let disponibles = (streams ?? []).filter {
            $0.works != false && $0.direccionValida != nil
        }

        // Preferimos HTTPS comprobando la dirección real.
        let segura = disponibles.first {
            $0.direccionValida?.scheme?.lowercased() == "https"
        }

        return (segura ?? disponibles.first)?.direccionValida
    }
}

// MARK: - Género

struct RadioGenre: Decodable {
    let text: String?
}

// MARK: - Ubicación

struct RadioLocation: Decodable {
    let countryName: String?
}

// MARK: - Transmisión de audio

struct RadioStream: Decodable {
    let url: String?
    let works: Bool?

    // MARK: - Validar dirección

    var direccionValida: URL? {
        guard
            let texto = url,
            let direccion = URL(string: texto),
            let esquema = direccion.scheme?.lowercased(),
            esquema == "https" || esquema == "http",
            direccion.host != nil
        else {
            return nil
        }

        return direccion
    }
}
