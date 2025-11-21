# Práctica 4 - Grupo 7

## 🧱 1. Descripción general

Este proyecto implementa un **modelo dimensional físico** y un **proceso ETL** utilizando **Pentaho Data Integration (PDI)** para poblar una base de datos dimensional en **MySQL**, a partir de las bases de datos operacionales.

El flujo de trabajo extrae, transforma y carga datos de las siguientes dimensiones:

* **Cliente**
* **Domicilio**
* **Proveedor**
* **Pago**
* **Tiempo**
* **Zona**
* **Tipo_Proveedor** (Eliminado tras re-entrega, denormalizando el modelo)
* **Repartidor**

⚠️ *Nota:* Falta incluir la carga de la **tabla de hechos (Hecho_Venta)**, la cual no se logró poblar ni generar empleando las claves primarias de las transformaciones generadas.

---

### ⚙️ 2. Requisitos previos

* **Sistema operativo:** Windows 11
* **Pentaho Data Integration (Spoon):** versión 9.0 o superior
* **MySQL Server:** versión 8.0 o superior
* **Conector JDBC de MySQL:**
  Archivo `mysql-connector-j-8.x.x.jar` ubicado en

  ```
  C:\Pentaho\data-integration\lib\
  ```
* **Base de datos fuente:**
  `tabi2025` (contiene las tablas operacionales)
* **Base de datos dimensional:**
  `dw_delivery` (debe crearse antes de ejecutar el ETL)

---

### 🧠 3. Descripción del flujo (main.kjb)

El job principal **Trabajo procesando dimensiones delivery.kjb** controla la ejecución de las transformaciones de carga de dimensiones.
El flujo general es el siguiente:

1. **Start** → Inicia el proceso.
2. **Carga de dimensiones:** se ejecutan las transformaciones para cada dimensión:

   * Cliente
   * Domicilio
   * Proveedor
   * Pago
   * Tiempo
   * Zona
   * Repartidor
3. Cada transformación carga su respectiva tabla en la base de datos dimensional.
4. Si todas las cargas finalizan correctamente, el flujo continúa a la etapa **Éxito**.
5. Si alguna transformación falla, el flujo deriva a **Abortar trabajo**, finalizando con error controlado.
6. En caso de éxito, se ejecuta la transformacion **Hecho_venta**, que marca el cierre del proceso ETL.

---

### 🧰 5. Instrucciones de ejecución

1. Abrir **Pentaho Data Integration (Spoon)**.
2. Abrir el archivo `Trabajo procesando dimensiones delivery.kjb`.
3. Verificar la conexión a la base de datos MySQL:

   * Host: `localhost`
   * Puerto: `3306`
   * Usuario: `root`
   * Contraseña: `comida`
   * Base de datos fuente: `tabi2025`
   * Base de datos destino: `dw_delivery`
4. Asegurar que las tablas del modelo dimensional estén creadas (definidas en `DDL SQL Struct.sql` ).
5. Ejecutar el **job principal** (`Trabajo procesando dimensiones delivery.kjb`).
6. Observar los resultados en la consola de ejecución:

   * Si todas las transformaciones se ejecutan correctamente, el flujo finaliza en **Éxito**.
   * En caso contrario, se activa el paso **Abortar trabajo**.

---

### 📦 6. Resultados esperados

* Tablas de dimensiones pobladas correctamente en la base de datos **dw_delivery**.
* Registros provenientes de la base de datos operacional **delivery_db** consolidados y depurados.
* Log de ejecución sin errores.

---

---

### 👥 8. Integrantes del grupo

* [Juan Volpe]
* [Franco Kumichel]

---
