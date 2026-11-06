import Foundation
import Observation

// MARK: - Comportamiento de la lista de televisión

@MainActor
@Observable
final class TVViewModel {

    // MARK: - Estado de la pantalla

    private(set) var canales: [TVChannel] = []
    private(set) var estaCargando = false
    private(set) var mensajeError: String?

    // MARK: - Control de carga

    private var cargaRealizada = false

    // MARK: - Manager

    private let manager = TVManager()
    
    // MARK: - Búsqueda de canales

    var textoBusqueda = ""

    var canalesFiltrados: [TVChannel] {
        let texto = textoBusqueda.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !texto.isEmpty else {
            return canales
        }

        return canales.filter {
            $0.nombre.localizedStandardContains(texto)
        }
    }

    // MARK: - Cargar canales

    func cargarCanales(forzar: Bool = false) async {
        guard !estaCargando else {
            return
        }

        guard forzar || !cargaRealizada else {
            return
        }

        estaCargando = true
        mensajeError = nil

        // Se ejecuta al terminar, tanto si hubo éxito como error.
        defer {
            estaCargando = false
        }

        do {
            let resultado = try await manager.obtenerCanales()

            try Task.checkCancellation()

            canales = resultado
            cargaRealizada = true

        } catch is CancellationError {
            // La pantalla dejó de necesitar la descarga.
        } catch let error as URLError where error.code == .cancelled {
            // URLSession también puede informar una cancelación.
        } catch {
            mensajeError = """
            No pudimos cargar los canales. Comprueba tu conexión e intenta nuevamente.
            """
        }
    }
}
