import Foundation

// MARK: - Modelo de canal de televisión

struct TVChannel: Identifiable {
    let id: String
    let nombre: String
    let streamURL: URL
}
