import SwiftUI

// MARK: - Lista de estaciones de radio

struct RadioListView: View {

    // MARK: - ViewModel

    @State private var viewModel = RadioViewModel()

    // MARK: - Contenido

    var body: some View {
        @Bindable var modelo = viewModel

        NavigationStack {
            Group {
                if viewModel.estaCargando {
                    ProgressView("Cargando estaciones…")
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity
                        )

                } else if let mensaje = viewModel.mensajeError {
                    pantallaError(mensaje)

                } else if viewModel.estaciones.isEmpty {
                    pantallaVacia

                } else if viewModel.estacionesFiltradas.isEmpty {
                    pantallaSinCoincidencias

                } else {
                    listaEstaciones
                }
            }
            .navigationTitle("Radio")
            .searchable(
                text: $modelo.textoBusqueda,
                prompt: "Buscar estación"
            )
            .task {
                await viewModel.cargarEstaciones()
            }
        }
    }

    // MARK: - Lista

    private var listaEstaciones: some View {
        List(viewModel.estacionesFiltradas) { estacion in
            NavigationLink {
                RadioPlayerView(estacion: estacion)
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: "radio")
                        .font(.title2)
                        .foregroundStyle(.indigo)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(estacion.name)
                            .font(.headline)

                        Text(estacion.genero)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text(estacion.pais)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if estacion.streamURL == nil {
                            Text("Transmisión no disponible")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                    }
                }
                .padding(.vertical, 6)
            }
        }
        .listStyle(.plain)
    }

    // MARK: - Sin resultados

    private var pantallaVacia: some View {
        ContentUnavailableView {
            Label(
                "No hay estaciones disponibles",
                systemImage: "radio"
            )
        } description: {
            Text("La API devolvió una lista vacía.")
        } actions: {
            botonReintentar
        }
    }

    // MARK: - Sin coincidencias de búsqueda

    private var pantallaSinCoincidencias: some View {
        ContentUnavailableView {
            Label(
                "No encontramos estaciones",
                systemImage: "magnifyingglass"
            )
        } description: {
            Text("Prueba con otro nombre o borra la búsqueda.")
        }
    }

    // MARK: - Error de descarga

    private func pantallaError(_ mensaje: String) -> some View {
        ContentUnavailableView {
            Label(
                "No pudimos cargar la radio",
                systemImage: "wifi.exclamationmark"
            )
        } description: {
            Text(mensaje)
        } actions: {
            botonReintentar
        }
    }

    // MARK: - Reintentar descarga

    private var botonReintentar: some View {
        Button("Intentar de nuevo") {
            Task {
                await viewModel.cargarEstaciones(forzar: true)
            }
        }
        .buttonStyle(.borderedProminent)
        .tint(.indigo)
    }
}

// MARK: - Vista previa

#Preview {
    RadioListView()
}
