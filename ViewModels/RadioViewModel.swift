import Foundation
import Observation

// MARK: - Comportamiento de la lista de radio

@MainActor
@Observable
final class RadioViewModel {

    // MARK: - Estado de la pantalla

    private(set) var estaciones: [RadioStation] = []
    private(set) var estaCargando = false
    private(set) var mensajeError: String?

    // MARK: - Control de carga

    private var cargaRealizada = false

    // MARK: - Manager

    private let manager = RadioManager()
    
    // MARK: - Búsqueda de estaciones

    var textoBusqueda = ""

    var estacionesFiltradas: [RadioStation] {
        let texto = textoBusqueda.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !texto.isEmpty else {
            return estaciones
        }

        return estaciones.filter {
            $0.name.localizedStandardContains(texto)
        }
    }

    // MARK: - Cargar estaciones

    func cargarEstaciones(forzar: Bool = false) async {
        guard !estaCargando else {
            return
        }

        guard forzar || !cargaRealizada else {
            return
        }

        estaCargando = true
        mensajeError = nil

        defer {
            estaCargando = false
        }

        do {
            let resultado = try await manager.obtenerEstaciones()

            try Task.checkCancellation()

            estaciones = resultado
            cargaRealizada = true

        } catch is CancellationError {
            // Es normal si la pantalla cancela su tarea.

        } catch let error as URLError where error.code == .cancelled {
            // URLSession también puede informar una cancelación.

        } catch let error as RadioError {
            mensajeError = error.localizedDescription

        } catch is DecodingError {
            mensajeError = """
            La respuesta de radio tiene un formato que no pudimos leer.
            """

        } catch {
            mensajeError = """
            No pudimos cargar las estaciones. Comprueba tu conexión \
            e intenta nuevamente.
            """
        }
    }
}
