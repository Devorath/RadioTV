import Foundation
import AVFoundation

// MARK: - Estado de la transmisión

enum TVPlaybackState {
    case cargando
    case reproduciendo
    case pausado
    case fallo
}

// MARK: - Control del reproductor

@MainActor
final class TVPlayerManager {

    // MARK: - Reproductor

    let player = AVPlayer()

    private var identificadorSesion: UUID?

    // MARK: - Iniciar transmisión

    func reproducir(url: URL) async throws {
        detener()

        try Task.checkCancellation()

        let identificador = UUID()
        identificadorSesion = identificador

        do {
            try await AudioSessionManager.shared.activar(
                para: identificador,
                esVideo: true
            )

            try Task.checkCancellation()

            // Evita reproducir si salimos durante la activación.
            guard identificadorSesion == identificador else {
                throw CancellationError()
            }

            let item = AVPlayerItem(url: url)
            player.replaceCurrentItem(with: item)
            player.play()

        } catch {
            // Limpiamos solo la solicitud que inició esta operación.
            if identificadorSesion == identificador {
                detener()
            }

            throw error
        }
    }

    // MARK: - Consultar estado

    func consultarEstado() -> TVPlaybackState {
        guard let item = player.currentItem else {
            return .fallo
        }

        if item.status == .failed || item.error != nil {
            return .fallo
        }

        switch player.timeControlStatus {
        case .playing:
            return .reproduciendo

        case .waitingToPlayAtSpecifiedRate:
            return .cargando

        case .paused:
            return item.status == .readyToPlay
                ? .pausado
                : .cargando

        @unknown default:
            return .cargando
        }
    }

    // MARK: - Detener transmisión

    func detener() {
        player.pause()
        player.replaceCurrentItem(with: nil)

        if let identificador = identificadorSesion {
            identificadorSesion = nil

            AudioSessionManager.shared.desactivar(
                para: identificador
            )
        }
    }
}
