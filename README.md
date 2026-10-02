# Gestión de Pedidos - Amasandería

## 1. Definición del Producto y Paradigma
En una amasandería, parte de su trabajo diario es administrar los pedidos anotándolos en papeles para pegarlos sobre la caja o registrarlos en una libreta. Esto genera un desorden operativo, facilitando errores al calcular manualmente los precios según el tipo de masa (frita o de horno) y su tamaño (cóctel, mediana o grande). Además, existe la posibilidad de olvidar algún pedido al pasarlo por alto, sumado al tedioso trabajo de contar a mano el total de masas que se deben preparar en la zona de panadería.

Para solucionar esto, se creó un prototipo funcional de una aplicación móvil que digitaliza el ingreso de pedidos. El sistema automatiza el cálculo de cobros mediante los precios ya definidos del negocio y genera un resumen diario para informar cuánto se requiere producir, optimizando los tiempos del local y evitando atrasos.

El entorno de una amasandería es dinámico y de movimiento constante; un sistema de escritorio anclaría la administración a un solo lugar. El paradigma móvil es la tecnología adecuada porque permite tomar los pedidos desde la caja o revisar la producción necesaria directamente desde el sector de panadería con un celular o tablet. Además, los dispositivos móviles son más compactos; en la zona de producción, un PC de escritorio quedaría inutilizable rápidamente por la gran cantidad de polvo en el aire producto de la harina. Finalmente, se eligió Flutter ya que su arquitectura basada en widgets facilita la creación de interfaces reactivas y modulares, garantizando un rendimiento fluido al manejar listas dinámicas.

## 2. Especificación de Requerimientos

### Historias de Usuario
* **HU1:** Como administrador de caja, quiero ingresar el tipo, tamaño y cantidad de masas en un formulario, para que la aplicación calcule el total a cobrar automáticamente sin errores.
* **HU2:** Como trabajador de panadería, quiero ver un resumen con el total de masas fritas y de horno agrupadas por tamaño para el día seleccionado, para planificar la producción y evitar atrasos.
* **HU3:** Como encargado del local, quiero tocar un pedido específico en el historial de ventas, para ver los detalles del cliente (como su contacto y estado de pago) y asegurar una entrega correcta.

### Matriz de Requerimientos
**Requerimientos Funcionales (RF):**
* **RF1:** El sistema debe contar con un formulario que registre los datos del cliente, contacto, fecha, hora, tipo de masa, medida y cantidad.
* **RF2:** El sistema debe calcular de manera automática el precio final del pedido basándose en las variables de tamaño y tipo de masa seleccionadas.
* **RF3:** El sistema debe mostrar un historial de pedidos permitiendo filtrar la vista por fechas específicas.
* **RF4:** El sistema debe calcular y mostrar la sumatoria total de unidades solicitadas en el día, agrupadas por sus características físicas.

**Requerimientos No Funcionales (RNF):**
* **RNF1:** La aplicación debe ser desarrollada utilizando el framework Flutter y el lenguaje Dart.
* **RNF2:** La navegación de lectura de datos debe implementar obligatoriamente el patrón de interfaz Master-Detail.
* **RNF3:** La estructura del código debe ser modular, separando los modelos de datos, las vistas (screens) y el diseño visual (theme).
* **RNF4:** La interfaz visual debe mantener coherencia utilizando un tema global de colores (AppTheme).

## 3. Arquitectura y Jerarquía de Navegación

**Justificación de la Arquitectura:**
Para este proyecto se adoptó una arquitectura modular basada en el principio de Separación de Responsabilidades (Separation of Concerns). El código se estructuró en directorios específicos dentro de la carpeta `lib/` para mantener el proyecto escalable y ordenado, dejando el archivo `main.dart` casi en blanco, funcionando exclusivamente como punto de arranque. La división es la siguiente:
*   **/models**: Contiene la definición y estructura pura de los datos (el modelo del pedido), aislando la lógica de información de la interfaz gráfica.
*   **/screens**: Agrupa todas las vistas de la aplicación (`Dashboard`, `Formulario`, `Lista` y `Detalle`), encargándose únicamente de la interfaz de usuario y sus estados.
*   **/theme**: Centraliza toda la configuración visual (paleta de colores morados, estilos de botones y textos) en un único archivo `app_theme.dart` para ser inyectado globalmente.

**Esquema Lógico de Navegación:**
El flujo principal de la aplicación es directo e interconectado a través de `Navigator.push`. Las pantallas se comunican de la siguiente forma para resolver el flujo de la amasandería:
1.  **DashboardScreen (Nodo Central):** Es la pantalla de inicio. Actúa como el menú principal bifurcando al usuario hacia la creación de un nuevo pedido o a la revisión del historial.
2.  **OrderFormScreen:** Pantalla operativa para ingresar datos, a la cual se ingresa directamente desde el botón principal del Dashboard.
3.  **OrderListScreen (Vista Master):** Accesible desde el Dashboard. Muestra la lista de pedidos filtrable por día.
4.  **OrderDetailScreen (Vista Detail):** Es el destino final del flujo de lectura. Solo se accede al tocar una tarjeta específica dentro de la `OrderListScreen`. La navegación hacia esta pantalla inyecta el objeto del pedido completo por parámetro, evitando procesar datos nuevamente.

## 4. Despliegue y Material de Apoyo

**Instrucciones de compilación y ejecución:**
Para desplegar este proyecto en un entorno local, se requiere tener instalado el SDK de Flutter y contar con un emulador Android/iOS o un dispositivo físico conectado. Ejecute los siguientes comandos en la terminal desde la carpeta raíz del proyecto:

1. Descargar e instalar las dependencias necesarias utilizando el siguiente comando en la consola:
   flutter pub get
2. Compilar y ejecutar la applicacion:
   flutter run
**Material de apoyo**
Video de exposicion técnica: https://drive.google.com/file/d/1Raqbi6RXQGuqcQemww9bj7WoCKzzooPq/view?usp=drivesdk