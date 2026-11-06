import Foundation
import Observation
import AVFoundation

// MARK: - Comportamiento del reproductor de televisión

@MainActor
@Observable
final class TVPlayerViewModel {

    // MARK: - Datos del canal

    let canal: TVChannel

    // MARK: - Estado de la pantalla

    private(set) var estaCargando = true
    private(set) var mensajeEstado = "Conectando con el canal…"
    private(set) var mensajeError: String?

    // MARK: - Manager

    private let manager = TVPlayerManager()

    // MARK: - Acceso al reproductor para VideoPlayer

    var player: AVPlayer {
        manager.player
    }

    // MARK: - Inicialización

    init(canal: TVChannel) {
        self.canal = canal
    }

    // MARK: - Iniciar y supervisar reproducción

    func reproducir() async {
        mensajeError = nil
        estaCargando = true
        mensajeEstado = "Conectando con el canal…"

        defer {
            detener()
        }

        do {
            try Task.checkCancellation()

            try await manager.reproducir(
                url: canal.streamURL
            )

            try Task.checkCancellation()

            let reloj = ContinuousClock()
            var inicioEspera = reloj.now
            var reproduccionIniciada = false

            while !Task.isCancelled {
                let estado = manager.consultarEstado()

                switch estado {
                case .reproduciendo:
                    reproduccionIniciada = true
                    estaCargando = false
                    mensajeEstado = "En reproducción"
                    inicioEspera = reloj.now

                case .pausado:
                    if reproduccionIniciada {
                        estaCargando = false
                        mensajeEstado = "En pausa"
                        inicioEspera = reloj.now
                    } else {
                        // Estar preparado no significa
                        // que la transmisión ya haya comenzado.
                        estaCargando = true
                        mensajeEstado = "Conectando con el canal…"
                    }

                case .cargando:
                    estaCargando = true
                    mensajeEstado = "Cargando transmisión…"

                case .fallo:
                    mostrarError()
                    return
                }

                if estaCargando &&
                    inicioEspera.duration(to: reloj.now) >= .seconds(25) {
                    mostrarError()
                    return
                }

                try await Task.sleep(for: .milliseconds(500))
            }

        } catch is CancellationError {
            // Salir de la pantalla cancela la reproducción.

        } catch {
            mostrarError()
        }
    }

    // MARK: - Mostrar contenido no disponible

    private func mostrarError() {
        estaCargando = false
        mensajeEstado = "Contenido no disponible"

        mensajeError = """
        No pudimos reproducir este canal. Puede estar fuera de servicio, \
        restringido o existir un problema de conexión. Intenta con otro canal.
        """
    }

    // MARK: - Detener reproducción

    func detener() {
        manager.detener()
        estaCargando = false
    }
}
