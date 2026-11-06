import Foundation
import AVFoundation

// MARK: - Estado de reproducción de radio

enum RadioPlaybackState {
    case cargando
    case reproduciendo
    case pausado
    case fallo
}

// MARK: - Control del reproductor de radio

@MainActor
final class RadioPlayerManager {
    
    // MARK: - Reproductor
    
    private let player = AVPlayer()
    private var pausaSolicitada = false
    private var identificadorSesion: UUID?
    
    // MARK: - Iniciar transmisión
    
    func reproducir(url: URL) async throws {
        detener()
        
        try Task.checkCancellation()
        
        let identificador = UUID()
        identificadorSesion = identificador
        
        try await AudioSessionManager.shared.activar(
            para: identificador,
            esVideo: false
        )
        
        try Task.checkCancellation()
        
        // Si salimos mientras se activaba el audio, no reproducimos.
        guard identificadorSesion == identificador else {
            throw CancellationError()
        }
        
        pausaSolicitada = false
        
        let item = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: item)
        player.play()
    }
    
    // MARK: - Pausar
    
    func pausar() {
        pausaSolicitada = true
        player.pause()
    }
    
    // MARK: - Reanudar
    
    func reanudar() {
        pausaSolicitada = false
        player.play()
    }
    
    // MARK: - Consultar estado
    
    func consultarEstado() -> RadioPlaybackState {
        guard let item = player.currentItem else {
            return .fallo
        }
        
        if item.status == .failed || item.error != nil {
            return .fallo
        }
        
        if pausaSolicitada {
            return .pausado
        }
        
        switch player.timeControlStatus {
        case .playing:
            return .reproduciendo
            
        case .waitingToPlayAtSpecifiedRate, .paused:
            return .cargando
            
        @unknown default:
            return .cargando
        }
    }
    
    // MARK: - Detener y liberar transmisión
    
    func detener() {
        player.pause()
        player.replaceCurrentItem(with: nil)
        pausaSolicitada = false
        
        if let identificador = identificadorSesion {
            identificadorSesion = nil
            
            AudioSessionManager.shared.desactivar(
                para: identificador
            )
        }
    }
}
