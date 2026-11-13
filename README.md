# Gestión de Pedidos - Amasandería (Prototipo Funcional - PDS2)

Aplicación móvil desarrollada en Flutter orientada a digitalizar y optimizar la administración de pedidos en una amasandería local, garantizando la persistencia local de datos y una arquitectura desacoplada bajo el estándar MVVM.

---

## 1. Definición del Producto y Paradigma
En el funcionamiento cotidiano de una amasandería, la administración tradicional se basa en anotar pedidos en papel y adherirlos a la caja o registrarlos en libretas físicas. Este flujo operativo genera un alto margen de error al calcular manualmente los precios según el tipo de masa (frita o de horno) y su tamaño (cóctel, mediana o grande), además del riesgo de pasar por alto encargos y la alta fricción al contabilizar manualmente la producción diaria para el área de panadería.

Para dar solución a esta problemática, se desarrolló un prototipo funcional móvil que centraliza y automatiza el registro, cálculo de cobros y control de entregas. La elección del paradigma móvil responde a las exigencias dinámicas del entorno: un sistema de escritorio anclaría la gestión a un espacio físico rígido, mientras que un dispositivo móvil permite operar desde la caja o consultar los requerimientos de producción directamente en el área de panadería. Asimismo, el factor de forma compacto evita las limitaciones de un computador tradicional en zonas con alta concentración de polvo en suspensión por harina. Se seleccionó **Flutter** debido a su capacidad para renderizar interfaces reactivas mediante widgets modulares y asegurar un rendimiento fluido en listas y calendarios dinámicos.

---

## 2. Especificación de Requerimientos

### Historias de Usuario (HU)
- **HU1:** Como administrador de caja, quiero ingresar los datos del cliente, tipo, tamaño y cantidad de masas en un formulario interactivo, para que la aplicación calcule el total a cobrar de manera automática y sin errores de cálculo.
- **HU2:** Como trabajador de panadería, quiero visualizar un resumen diario agrupado por características físicas y totales de masas fritas y de horno, para planificar la producción y evitar retrasos operativos.
- **HU3:** Como encargado del local, quiero seleccionar un pedido específico desde el historial para consultar los detalles de contacto, cambiar los estados de entrega y asegurar una trazabilidad correcta.

### Matriz de Requerimientos
**Requerimientos Funcionales (RF):**
- **RF1:** El sistema cuenta con un formulario robusto para el registro de nombre, contacto, fecha, hora, tipo de masa, medida y cantidad de unidades.
- **RF2:** El sistema calcula de forma dinámica el precio final del pedido a partir de las reglas de negocio de tamaño y tipología de masas.
- **RF3:** El sistema incorpora una vista de historial basada en calendarios interactivos con indicadores visuales de fechas activas y filtrado por día.
- **RF4:** El sistema procesa y despliega un resumen diario con la sumatoria desglosada por categoría de producción (Horno / Frita).
- **RF5:** El sistema integra un módulo de valoración In-App (Beta Testing) que lee un archivo JSON estático y emite reportes mediante interoperabilidad nativa (`share_plus`).

**Requerimientos No Funcionales (RNF):**
- **RNF1:** La solución se encuentra construida bajo el framework Flutter utilizando el lenguaje Dart.
- **RNF2:** El diseño de navegación implementa de forma estricta componentes estructurados de lectura y flujos desacoplados.
- **RNF3:** La arquitectura del software sigue un diseño modular bajo el patrón **MVVM**, aislando modelos, vistas, viewmodels y servicios de persistencia.
- **RNF4:** La interfaz gráfica respeta una identidad visual global centralizada mediante un tema unificado (`AppTheme`).

---

## 3. Arquitectura y Estructura del Proyecto (MVVM)

El proyecto implementa estrictamente el patrón **MVVM (Model-View-ViewModel)** en conjunto con el gestor de estado `Provider`, desacoplando por completo la lógica de negocio y las consultas de base de datos de las interfaces visuales:

- **`/lib/models`**: Contiene la clase de dominio `Order` encargada de modelar la estructura de los pedidos y su serialización bidireccional (`toMap` / `fromMap`) para SQLite.
- **`/lib/viewmodels`**: Aloja el `OrderViewModel` (extendiendo de `ChangeNotifier`), responsable de centralizar la lógica asíncrona de carga, inserción, actualización de estados de entrega y eliminación, notificando reactivamente a las vistas.
- **`/lib/services`**: Concentra la capa de persistencia local mediante `DatabaseHelper` (SQLite, `version: 2`), incorporando control de esquemas y reglas de negocio automatizadas (como el marcado de pedidos no retirados por antigüedad).
- **`/lib/screens`**: Agrupa las vistas declarativas limpias de lógica directa (`Dashboard`, `OrderForm`, `OrderList`, `OrderDetail` y `QaFeedback`).
- **`/lib/themes`**: Centraliza los estilos globales y la paleta de colores corporativa en `app_theme.dart`.

---

## 4. Estrategia de Calidad y Beta Testing (QA)

Con el fin de validar el prototipo en un entorno real, se implementó el módulo de evaluación dinámico exigido por la pauta, el cual procesa un instrumento estructurado en formato JSON (`assets/encuesta_qa.json`) con métricas orientadas a Historias de Usuario y Usabilidad[cite: 10, 20].

* **Muestra de Validación (10 usuarios reales):**
  * 4 x Participantes de la iniciativa "Workspace Mobile Firsts"[cite: 4].
  * 3 x Conocedores de la industria gastronómica/tecnológica[cite: 4].
  * 3 x Usuarios externos[cite: 4].
* **Reporte Ejecutivo de Resultados:**
  * **Qué funcionó:** La inmediatez de la persistencia local sin tiempos de carga notables, la utilidad del calendario con puntos indicadores de carga diaria y la simpleza del cambio de estados de entrega en terreno.
  * **Qué falló / Dificultades:** Algunos evaluadores señalaron no les agrado del todo el color y declararon que la pantalla de Pedidos podria mejorar al tener como primera vista el calendario y luego los pedidos.
  * **Deuda Técnica (Trabajos Futuros):** Implementar sincronización opcional en la nube y desarrollar la vista consolidada de cuentas pendientes para clientes que cancelan a fin de mes.

---

## 5. Despliegue y Material de Apoyo

## Despliegue, Binarios y Material de Apoyo

Los artefactos ejecutables y el material documental correspondiente al prototipo funcional **v1.0.0-beta (TRL 4)** se encuentran disponibles en los siguientes enlaces:

* **Instalador Android (`.apk`):** [Descargar desde GitHub Releases (v1.0.0-beta)](https://github.com/romimir/gestion_amasanderia/releases)
* **Presentación Ejecutiva (PDF) y Pitch:** https://drive.google.com/drive/folders/131WTJ2uHUqS8EbH0IqIggtWmvTq_pB-x?usp=sharing

### Guía de instalación en Android
1. Descarga el archivo `gestion-amasanderia-v1.0.0-beta.apk` desde la sección **Releases** de este repositorio.
2. Habilita el permiso para instalar aplicaciones de fuentes desconocidas en el dispositivo Android si el sistema lo solicita.
3. Ejecuta la aplicación instalada bajo el paquete `com.gestion_amasanderia` (**Amasandería La Lela**); el sistema opera de forma autónoma y sin conexión mediante persistencia local en SQLite.