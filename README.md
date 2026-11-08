# RadioTV

## Proyecto final del Módulo 9

RadioTV es una aplicación para iPhone que permite escuchar estaciones de radio y ver canales de televisión por internet. La desarrollé como proyecto final para reunir lo aprendido sobre SwiftUI, reproducción de audio y video, manejo de sesión y arquitectura MVVM.

La idea es: iniciar sesión, elegir Radio o TV, buscar una estación o canal y reproducir su transmisión.

## Funciones de la aplicación

- Inicio de sesión con un usuario fijo y mensajes cuando los datos son incorrectos.
- Sesión guardada en Keychain para conservar el acceso al volver a abrir la app.
- Cierre de sesión desde la pestaña Cuenta.
- Consulta de estaciones de radio mediante RapidAPI, con nombre, género y país.
- Descarga y lectura de una lista M3U de canales de televisión de México.
- Reproducción de radio con controles para pausar y reanudar.
- Reproducción de televisión con los controles de VideoPlayer.
- Detención de la transmisión al abandonar el reproductor.
- Mensajes de carga, listas vacías, errores de descarga y contenido no disponible.
- Buscadores por nombre en Radio y TV, que filtran los datos ya descargados.

La búsqueda de radio se realiza sobre las 20 estaciones obtenidas en la consulta, no sobre todo el catálogo de la API.

## Requisitos para abrir el proyecto

- Una Mac con Xcode y un SDK de iOS compatible con el proyecto.
- Un simulador de iPhone con iOS 17.6 o superior, de acuerdo con el destino mínimo configurado.
- Conexión a internet para consultar las listas y reproducir transmisiones.
- Una cuenta de RapidAPI con acceso a la API “50K Radio Stations” para utilizar Radio.

El proyecto utiliza frameworks de Apple y no requiere instalar librerías externas.

## Cómo ejecutarlo

1. Descomprime el proyecto en una carpeta de tu Mac.
2. Abre `RadioTV.xcodeproj` con Xcode.
3. Selecciona el esquema `RadioTV` y un simulador de iPhone compatible.
4. Configura tu clave de RapidAPI como se explica más abajo.
5. Selecciona **Product → Clean Build Folder** para limpiar la compilación.
6. Presiona **⌘ + R** para compilar y ejecutar.

Para usar el simulador no es necesario seleccionar un iPhone físico.

## Datos de acceso

La aplicación no incluye registro de usuarios. Para este ejercicio se utiliza la siguiente cuenta de prueba:

| Campo | Valor |
|---|---|
| Usuario | `USUARIO` |
| Contraseña | `CONTRASEÑA` |

Si los datos son incorrectos, aparece un mensaje en la pantalla de inicio de sesión. Al entrar correctamente se guarda una marca de sesión en Keychain; no se guarda la contraseña en UserDefaults.

Para volver al login, abre **Cuenta → Cerrar sesión**.

## Configuración de RapidAPI

La clave personal no debe incluirse en el repositorio ni en la entrega. La copia para compartir debe conservar `Services/APIConfig.swift` con un marcador para que el proyecto pueda compilar.

1. Crea una cuenta o inicia sesión en [RapidAPI](https://rapidapi.com/).
2. Busca **50K Radio Stations** y activa un plan apropiado, revisando sus condiciones y límites.
3. Obtén tu clave personal.
4. Abre `Services/APIConfig.swift` y sustituye únicamente el marcador:

```swift
static let rapidAPIKey = "COLOCA_AQUI_TU_CLAVE"
```

5. Guarda el archivo y ejecuta la aplicación.

Si no configuras la clave, Radio mostrará un aviso. TV utiliza una fuente independiente y no necesita esa clave.

La petición de radio utilizada es:

```text
GET https://50k-radio-stations.p.rapidapi.com/radios/random?limit=20
```

Incluye las cabeceras `x-rapidapi-host` y `x-rapidapi-key`. El endpoint devuelve estaciones aleatorias, por lo que los resultados pueden cambiar entre consultas. La aplicación evita repetir una descarga exitosa durante la vida del ViewModel de la lista.

Antes de compartir una copia, vuelve a colocar el marcador. Para trabajar con Git, excluye el archivo que contiene la clave real y proporciona una plantilla sin secretos con instrucciones para recrearlo.

## Fuente de televisión

Los canales se obtienen de:

```text
https://iptv-org.github.io/iptv/countries/mx.m3u
```

La aplicación descarga el archivo con URLSession. Después lee las etiquetas `#EXTINF`, obtiene el nombre situado después de la última coma y lo relaciona con la dirección de transmisión. Cada resultado se convierte en un modelo `TVChannel`.

## Organización del código

| Carpeta | Contenido |
|---|---|
| `Models` | Modelos de estaciones, transmisiones y canales. |
| `Services` | Managers para autenticación, Keychain, descargas y reproducción. |
| `ViewModels` | Estado y comportamiento de las pantallas. |
| `Views` | Pantallas de SwiftUI. |

El flujo de trabajo es **View → ViewModel → Manager**. Las vistas muestran la información y solicitan acciones al ViewModel; los Managers realizan las operaciones correspondientes.

Los ViewModels utilizan `@MainActor` y `@Observable`. Las vistas propietarias los conservan con `@State`, y utilizan `@Bindable` cuando necesitan editar sus propiedades. Los estados que solo debe modificar el ViewModel se declaran con `private(set)`.

Los comentarios `// MARK:` separan las secciones para que resulte más fácil localizar cada parte del código.

## Audio, video y conexiones HTTP

La radio utiliza AVPlayer y la categoría `.playback` de AVAudioSession. La televisión utiliza VideoPlayer de AVKit. Un `AudioSessionManager` compartido organiza la activación y desactivación del audio fuera del hilo principal.

Algunas transmisiones utilizan HTTP. Por eso, `Info.plist` incluye `NSAllowsArbitraryLoadsForMedia` dentro de `NSAppTransportSecurity`. Durante las pruebas también se añadió una excepción específica para `kepler.shoutca.st`. Esto no garantiza acceso HTTP a todos los dominios mediante URLSession.

## Si una estación o canal no funciona

Que un nombre aparezca en la lista no garantiza que su transmisión esté disponible. Algunos servidores pueden estar apagados, tener restricciones o utilizar formatos que el reproductor no pueda reproducir.

La app muestra un aviso de contenido no disponible cuando detecta un fallo o cuando se supera el tiempo de espera supervisado. En ese caso, regresa a la lista y prueba otra opción.

| Situación | Qué revisar |
|---|---|
| Radio solicita configurar la clave | Colocar la clave personal en `APIConfig.swift`. |
| La API rechaza la petición | Revisar la clave, la suscripción y los límites del plan. |
| No se descargan las listas | Comprobar la conexión a internet e intentar nuevamente. |
| Solo falla una transmisión | Probar otra estación o canal; el servidor puede no estar disponible. |
| Aparece el error `-1022` | Revisar el dominio bloqueado y la configuración ATS de la copia instalada. |
| No se escucha ninguna transmisión | Revisar el volumen y la salida de audio del Mac y del simulador. |

## Comprobación antes de entregar

- Iniciar sesión con campos vacíos y con credenciales incorrectas.
- Entrar con la cuenta de prueba, cerrar la app y comprobar que conserva la sesión.
- Cerrar sesión y verificar que al abrir nuevamente aparece el login.
- Cargar Radio y TV y buscar por nombre.
- Comprobar el aviso cuando una búsqueda no tiene coincidencias.
- Escuchar una estación, pausar y reanudar.
- Reproducir un canal con imagen y sonido.
- Salir de cada reproductor y cambiar de pestaña para comprobar que se detiene.
- Comprobar los avisos de descarga fallida y transmisión no disponible.
- Limpiar y compilar la copia de entrega sin incluir la clave personal.

## Lo que reafirme

Este proyecto me ayudó a reafirmar los conocimientos de conexión las pantallas con la lógica de la aplicación y con los servicios externos. También al realizar la descarga de una lista correctamente no significa que todas sus transmisiones funcionen: es necesario contemplar errores, informar a la persona y permitirle continuar usando la app.
