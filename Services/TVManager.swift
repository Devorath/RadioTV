import Foundation

// MARK: - Errores de descarga

enum TVError: LocalizedError {
    case respuestaInvalida
    case codigoHTTP(Int)
    case textoInvalido

    var errorDescription: String? {
        switch self {
        case .respuestaInvalida:
            return "El servidor no devolvió una respuesta válida."

        case .codigoHTTP(let codigo):
            return "No se pudo descargar la lista. Código: \(codigo)."

        case .textoInvalido:
            return "No se pudo leer la lista de canales."
        }
    }
}

// MARK: - Descarga y lectura de canales

struct TVManager {

    // MARK: - Fuente de datos

    private let listaURL = URL(
        string: "https://iptv-org.github.io/iptv/countries/mx.m3u"
    )!

    // MARK: - Obtener canales

    func obtenerCanales() async throws -> [TVChannel] {
        var solicitud = URLRequest(url: listaURL)
        solicitud.timeoutInterval = 30

        let (datos, respuesta) = try await URLSession.shared.data(
            for: solicitud
        )

        guard let respuestaHTTP = respuesta as? HTTPURLResponse else {
            throw TVError.respuestaInvalida
        }

        guard (200...299).contains(respuestaHTTP.statusCode) else {
            throw TVError.codigoHTTP(respuestaHTTP.statusCode)
        }

        guard let texto = String(data: datos, encoding: .utf8) else {
            throw TVError.textoInvalido
        }

        return interpretarLista(texto)
    }

    // MARK: - Interpretar archivo M3U

    private func interpretarLista(_ texto: String) -> [TVChannel] {
        var canales: [TVChannel] = []
        var nombrePendiente: String?
        var direccionesAgregadas = Set<String>()

        for lineaOriginal in texto.components(separatedBy: .newlines) {
            let linea = lineaOriginal.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

            guard !linea.isEmpty else {
                continue
            }

            if linea.hasPrefix("#EXTINF:") {
                nombrePendiente = nil

                // El documento indica que el nombre está
                // después de la última coma.
                if let coma = linea.lastIndex(of: ",") {
                    let nombre = String(linea[linea.index(after: coma)...])
                        .trimmingCharacters(in: .whitespacesAndNewlines)

                    if !nombre.isEmpty {
                        nombrePendiente = nombre
                    }
                }

                continue
            }

            // Ignoramos comentarios y otras etiquetas del archivo.
            guard !linea.hasPrefix("#") else {
                continue
            }

            guard let nombre = nombrePendiente else {
                continue
            }

            nombrePendiente = nil

            guard
                let url = URL(string: linea),
                let esquema = url.scheme?.lowercased(),
                esquema == "https" || esquema == "http",
                url.host != nil
            else {
                continue
            }

            // Evitamos repetir canales con la misma dirección.
            guard direccionesAgregadas.insert(url.absoluteString).inserted else {
                continue
            }

            canales.append(
                TVChannel(
                    id: url.absoluteString,
                    nombre: nombre,
                    streamURL: url
                )
            )
        }

        return canales.sorted {
            $0.nombre.localizedCaseInsensitiveCompare($1.nombre)
                == .orderedAscending
        }
    }
}
