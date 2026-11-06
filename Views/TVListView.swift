import SwiftUI

// MARK: - Lista de canales de televisión

struct TVListView: View {

    // MARK: - ViewModel

    @State private var viewModel = TVViewModel()

    // MARK: - Contenido

    var body: some View {
        @Bindable var modelo = viewModel

        NavigationStack {
            Group {
                if viewModel.estaCargando {
                    ProgressView("Cargando canales…")
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity
                        )

                } else if let mensaje = viewModel.mensajeError {
                    pantallaError(mensaje)

                } else if viewModel.canales.isEmpty {
                    pantallaVacia

                } else if viewModel.canalesFiltrados.isEmpty {
                    pantallaSinCoincidencias

                } else {
                    listaCanales
                }
            }
            .navigationTitle("Televisión")
            .searchable(
                text: $modelo.textoBusqueda,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Buscar canal"
            )
            .task {
                await viewModel.cargarCanales()
            }
        }
    }

    // MARK: - Lista

    private var listaCanales: some View {
        List(viewModel.canalesFiltrados) { canal in
            NavigationLink {
                TVPlayerView(canal: canal)
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: "tv")
                        .font(.title2)
                        .foregroundStyle(.indigo)
                        .accessibilityHidden(true)

                    Text(canal.nombre)
                        .font(.headline)
                }
                .padding(.vertical, 6)
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.cargarCanales(forzar: true)
        }
    }

    // MARK: - Sin resultados

    private var pantallaVacia: some View {
        ContentUnavailableView {
            Label(
                "No hay canales disponibles",
                systemImage: "tv.slash"
            )
        } description: {
            Text("La lista no contiene canales que podamos mostrar.")
        } actions: {
            botonReintentar
        }
    }

    // MARK: - Sin coincidencias de búsqueda

    private var pantallaSinCoincidencias: some View {
        ContentUnavailableView {
            Label(
                "No encontramos canales",
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
                "No pudimos cargar la televisión",
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
                await viewModel.cargarCanales(forzar: true)
            }
        }
        .buttonStyle(.borderedProminent)
        .tint(.indigo)
    }
}

// MARK: - Vista previa

#Preview {
    TVListView()
}
