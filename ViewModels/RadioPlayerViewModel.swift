import Foundation
import Observation

// MARK: - Comportamiento del reproductor de radio

@MainActor
@Observable
final class RadioPlayerViewModel {

    // MARK: - Estación seleccionada

    let estacion: RadioStation

    // MARK: - Estado de la pantalla

    private(set) var estaCargando = true
    private(set) var estaPausado = false
    private(set) var puedeControlar = false
    private(set) var mensajeEstado = "Conectando con la estación…"
    private(set) var mensajeError: String?

    // MARK: - Manager

    private let manager = RadioPlayerManager()

    // MARK: - Inicialización

    init(estacion: RadioStation) {
        self.estacion = estacion
    }

    // MARK: - Iniciar y supervisar reproducción

    func reproducir() async {
        mensajeError = nil
        estaCargando = true
        estaPausado = false
        puedeControlar = false
        mensajeEstado = "Conectando con la estación…"

        defer {
            detener()
        }

        guard let url = estacion.streamURL else {
            mostrarError()
            return
        }

        do {
            try Task.checkCancellation()
            try await manager.reproducir(url: url)

            let reloj = ContinuousClock()
            var inicioEspera = reloj.now

            while !Task.isCancelled {
                switch manager.consultarEstado() {
                case .reproduciendo:
                    estaCargando = false
                    estaPausado = false
                    puedeControlar = true
                    mensajeEstado = "En reproducción"
                    inicioEspera = reloj.now

                case .pausado:
                    estaCargando = false
                    estaPausado = true
                    puedeControlar = true
                    mensajeEstado = "En pausa"
                    inicioEspera = reloj.now

                case .cargando:
                    estaCargando = true
                    estaPausado = false
                    mensajeEstado = "Cargando transmisión…"

                    if inicioEspera.duration(to: reloj.now) >= .seconds(25) {
                        mostrarError()
                        return
                    }

                case .fallo:
                    mostrarError()
                    return
                }

                try await Task.sleep(for: .milliseconds(500))
            }

        } catch is CancellationError {
            // Es normal cuando abandonamos el reproductor.

        } catch {
            mostrarError()
        }
    }

    // MARK: - Pausar o reanudar

    func alternarReproduccion() {
        guard puedeControlar, mensajeError == nil else {
            return
        }

        if estaPausado {
            manager.reanudar()

            estaPausado = false
            estaCargando = true
            mensajeEstado = "Conectando con la estación…"

        } else {
            manager.pausar()

            estaPausado = true
            estaCargando = false
            mensajeEstado = "En pausa"
        }
    }

    // MARK: - Mostrar contenido no disponible

    private func mostrarError() {
        estaCargando = false
        puedeControlar = false
        mensajeEstado = "Contenido no disponible"

        mensajeError = """
        No pudimos reproducir esta estación. Puede estar fuera de servicio, \
        restringida o existir un problema de conexión. Intenta con otra estación.
        """
    }

    // MARK: - Detener reproducción

    func detener() {
        manager.detener()
        estaCargando = false
        estaPausado = false
        puedeControlar = false
    }
}
