# Architecture Decision Record (ADR)
## PoC: Persistencia Offline Local con SQLite (`sqflite`)

- **Módulo:** Programación para Dispositivos Móviles
- **Proyecto:** Gestión Amasandería (Agendamiento de Pedidos)
- **Rama de Experimentación:** `feature/poc_sqlite`
- **Estado:** Validado / Listo para integración

---

## 1. Contexto y Riesgo Evaluado

En la maqueta funcional inicial (PDS1), los pedidos no contaban con almacenamiento persistente real; la pantalla `order_list_screen.dart` solo renderizaba datos estáticos o temporales en memoria. Esta estructura implicaba un riesgo técnico claro:

1. **Pérdida de información por cierre del sistema (LMK):** Ante falta de recursos en el dispositivo, el sistema operativo (Android/iOS) puede matar el proceso en segundo plano (*Low Memory Killer*), borrando cualquier pedido guardado temporalmente.

Para aislar y solucionar este problema antes de construir la lógica definitiva en las pantallas, se desarrolló esta Prueba de Concepto (PoC) centrada exclusivamente en implementar **persistencia no volátil en disco duro**, aislando la base de datos sin interferir con la interfaz final.

---

## 2. Decisión Técnica Adoptada

Se seleccionó el motor relacional **SQLite** mediante paquetes oficiales de Pub.dev:

- `sqflite`: Manejo de base de datos relacional local en Flutter.
- `path` y `path_provider`: Obtención de rutas internas y seguras en el almacenamiento del dispositivo.

### Patrón de Arquitectura e Implementación
- **Patrón Singleton (`DatabaseService`):** Se centralizó el acceso a SQLite en una sola instancia global para evitar aperturas concurrentes o bloqueos en el archivo `.db`.
- **Data Transfer Object (`Order`):** Mapeo explícito mediante los métodos `toMap()` y `fromMap()` para transformar la entidad del pedido a mapas compatibles con SQL.
- **Control de Asincronía y Excepciones:** Operaciones ejecutadas con `Future` / `async` / `await` envueltas en bloques `try-catch`, incorporando la verificación `if (!mounted) return;` para evitar errores de contexto asíncrono en la UI.
- **Limpieza de Base de Datos y Secuencia:** Consultas SQL para eliminar registros y limpiar la tabla del sistema `sqlite_sequence`, logrando que al vaciar la base de datos el contador `AUTOINCREMENT` vuelva al ID #1.

---

## 3. Consecuencias y Resultados de la PoC

### Impacto Positivo
- **Persistencia comprobada:** Se verificó que los pedidos se mantienen guardados en el disco local aunque se cierre por completo la aplicación en el emulador.
- **Transacciones eficientes:** Consultas y escrituras asíncronas en milisegundos sin congelar el hilo de la interfaz.
- **Cálculo de negocio validado:** Reglas de precio oficial ($220, $210, $200, $190, $180 según tipo y tamaño) y rangos aleatorios de volumen (10 a 200 unidades) probados sin errores.

### Limitaciones y Consideraciones
- **Evolución del esquema:** Si a futuro se modifican los campos de la tabla `pedidos`, se deberá gestionar la migración usando la propiedad `onUpgrade` dentro de `openDatabase`.
- **Aislamiento de la UI:** La interfaz usada en `lib/main.dart` es estrictamente técnica y temporal para validar la base de datos, por lo que no se usará en la versión final.

---

## 4. Plan de Fusión e Integración a la Rama Principal (`main`)

Para pasar esta solución a la rama `main` sin romper la estructura existente:

1. **Restaurar `lib/main.dart`:** Volver al punto de entrada original del proyecto con la navegación hacia el Dashboard.
2. **Mantener Capa de Persistencia:** Conservar intactos los archivos `lib/services/database_service.dart` y `lib/models/order_model.dart`.
3. **Conectar Pantallas Definitivas:**
   - En `order_from_screen.dart`: Reemplazar la lógica temporal invocando `DatabaseService.instance.insertPedido()`.
   - En `order_list_screen.dart`: Cargar el listado real llamando a `DatabaseService.instance.fetchPedidos()`.
4. **Fusión en Git:**
    - En git bash salir a la rama principal y fusionar las rama poc_sqlite con la rama principal
        git checkout main
        git merge feature/poc_sqlite
        git push origin main