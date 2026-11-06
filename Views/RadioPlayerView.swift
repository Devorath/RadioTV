import SwiftUI

// MARK: - Pantalla de reproducción de radio

struct RadioPlayerView: View {

    // MARK: - ViewModel

    @State private var viewModel: RadioPlayerViewModel
    
    @Environment(\.scenePhase) private var scenePhase

    // MARK: - Inicialización

    init(estacion: RadioStation) {
        _viewModel = State(
            initialValue: RadioPlayerViewModel(estacion: estacion)
        )
    }

    // MARK: - Contenido

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                if let mensaje = viewModel.mensajeError {
                    pantallaError(mensaje)
                } else {
                    informacionEstacion
                    controles
                }
            }
            .frame(maxWidth: 440)
            .padding(24)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Escuchando")
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
    
    

    // MARK: - Información de la estación

    private var informacionEstacion: some View {
        VStack(spacing: 16) {
            Image(systemName: "radio.fill")
                .font(.system(size: 88))
                .foregroundStyle(.indigo)
                .padding(.top, 40)
                .accessibilityHidden(true)

            Text(viewModel.estacion.name)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text(viewModel.estacion.genero)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Label(
                viewModel.estacion.pais,
                systemImage: "globe"
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
    }

    // MARK: - Estado y controles

    private var controles: some View {
        VStack(spacing: 20) {
            if viewModel.estaCargando {
                ProgressView()
            }

            Text(viewModel.mensajeEstado)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button {
                viewModel.alternarReproduccion()
            } label: {
                Label(
                    viewModel.estaPausado ? "Reanudar" : "Pausar",
                    systemImage: viewModel.estaPausado
                        ? "play.fill"
                        : "pause.fill"
                )
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .tint(.indigo)
            .disabled(!viewModel.puedeControlar)
        }
    }

    // MARK: - Contenido no disponible

    private func pantallaError(_ mensaje: String) -> some View {
        ContentUnavailableView {
            Label(
                "Estación no disponible",
                systemImage: "speaker.slash"
            )
        } description: {
            Text(mensaje)
        }
    }
}
