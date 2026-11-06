import SwiftUI
import AVKit

// MARK: - Pantalla de reproducción de televisión

struct TVPlayerView: View {

    // MARK: - ViewModel

    @State private var viewModel: TVPlayerViewModel
    
    @Environment(\.scenePhase) private var scenePhase

    // MARK: - Inicialización

    init(canal: TVChannel) {
        _viewModel = State(
            initialValue: TVPlayerViewModel(canal: canal)
        )
    }

    // MARK: - Contenido

    var body: some View {
        VStack(spacing: 24) {
            if let mensaje = viewModel.mensajeError {
                pantallaError(mensaje)
            } else {
                reproductor

                VStack(spacing: 12) {
                    Text(viewModel.canal.nombre)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)

                    if viewModel.estaCargando {
                        ProgressView()
                    }

                    Text(viewModel.mensajeEstado)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                Spacer()
            }
        }
        .navigationTitle("En vivo")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.reproducir()
        }
        .onDisappear {
            viewModel.detener()
        }
        
        .onChange(of: scenePhase) { _, nuevaFase in
            if nuevaFase != .active {
                viewModel.detener()
            }
        }
    }

    // MARK: - Reproductor de video

    private var reproductor: some View {
        VideoPlayer(player: viewModel.player)
            .aspectRatio(16.0 / 9.0, contentMode: .fit)
            .background(.black)
    }

    // MARK: - Contenido no disponible

    private func pantallaError(_ mensaje: String) -> some View {
        ContentUnavailableView {
            Label(
                "Canal no disponible",
                systemImage: "tv.slash"
            )
        } description: {
            Text(mensaje)
        }
    }
}
