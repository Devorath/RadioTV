import Foundation
import AVFoundation
import Dispatch

// MARK: - Sesión de audio compartida

@MainActor
final class AudioSessionManager {

    // MARK: - Instancia compartida

    static let shared = AudioSessionManager()

    // MARK: - Control de acceso

    private var propietario: UUID?

    private let cola = DispatchQueue(
        label: "com.devorath.RadioTV.audioSession"
    )

    private init() {}

    // MARK: - Activar sesión

    func activar(para identificador: UUID, esVideo: Bool) async throws {
        propietario = identificador

        try await withCheckedThrowingContinuation {
            (continuacion: CheckedContinuation<Void, Error>) in

            cola.async {
                do {
                    let sesion = AVAudioSession.sharedInstance()

                    try sesion.setCategory(
                        .playback,
                        mode: esVideo ? .moviePlayback : .default
                    )

                    try sesion.setActive(true)

                    continuacion.resume()
                } catch {
                    continuacion.resume(throwing: error)
                }
            }
        }
    }

    // MARK: - Desactivar sesión

    func desactivar(para identificador: UUID) {
        // Un reproductor anterior no debe apagar el audio del nuevo.
        guard propietario == identificador else {
            return
        }

        propietario = nil

        cola.async {
            do {
                try AVAudioSession.sharedInstance().setActive(
                    false,
                    options: .notifyOthersOnDeactivation
                )
            } catch {
                #if DEBUG
                print("No se pudo desactivar el audio: \(error)")
                #endif
            }
        }
    }
}
