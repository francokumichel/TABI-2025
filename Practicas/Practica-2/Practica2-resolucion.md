# Práctica 2

1-. Copiar 6 consultas de la práctica anterior, y sombrear con `<span style="color:orange;">`color naranja los términos correspondientes a dimensiones y con `<span style="color:green;">`color verde los términos correspondientes a medidas.

`<span style="color:green">`

`<span style="color:orange">`

Comentarios:

- **Rol: Gerente de ventas**

  1. `<span style="color:orange">`Zonas donde se registraron más `<span style="color:green">`ventas en un `<span style="color:orange">`periodo dado.
  2. Listado de `<span style="color: orange">`Fecha y hora  donde se registraron `<span style="color:green">`más ventas, ordenados en orden descendente.
  3. Top 10 `<span style="color: orange">`zonas donde se registraron los mayores `<span style="color:green">`acumulados de descuentos por promoción.
- **Rol: Gerente de proveedores**

  1. `<span style="color: orange">`Nombre y tipo de proveedores que lograron más alcance en `<span style="color:green">`distintos clientes.
  2. Top 3 `<span style="color: orange">`tipos de proveedores que generaron mayor `<span style="color:green">`cantidad de ventas por `<span style="color: orange">`zona.
  3. `<span style="color: orange">`Proveedores que realizaron ventas con `<span style="color:green">`descuento por promoción mayor a $5000 en un determinado `<span style="color:orange">`horario por `<span style="color:orange">`zona.



## ✅ 2) Consultas en SQL:

###### *1.*

```sql

SELECT dz.nombre AS zona,
       COUNT(v.id) AS total_ventas
FROM venta v
JOIN cliente c ON v.cliente_id = c.id
JOIN domicilio d ON c.domicilio_id = d.id
JOIN domicilio_zona dz ON d.zona_id = dz.id
WHERE v.fecha_hora BETWEEN '2025-01-01' AND '2025-01-31'
GROUP BY dz.nombre
ORDER BY total_ventas DESC;
```

###### *2.*

```sql

SELECT CAST(v.fecha_hora AS DATE) AS fecha,
       COUNT(v.id) AS total_ventas
FROM venta v
GROUP BY CAST(v.fecha_hora AS DATE)
ORDER BY total_ventas DESC;
```

###### *3.*

```sql

SELECT dz.nombre AS zona,
       SUM(v.descuento_promocion) AS total_descuento
FROM venta v
JOIN cliente c ON v.cliente_id = c.id
JOIN domicilio d ON c.domicilio_id = d.id
JOIN domicilio_zona dz ON d.zona_id = dz.id
GROUP BY dz.nombre
ORDER BY total_descuento DESC
LIMIT 10;
```

###### *4.*

```sql

SELECT p.nombre AS proveedor,
       tp.descripcion AS tipo_proveedor,
       COUNT(DISTINCT v.cliente_id) AS clientes_distintos
FROM venta v
JOIN proveedor p ON v.proveedor_id = p.id
JOIN tipo_proveedor tp ON p.tipo_id = tp.id
GROUP BY p.nombre, tp.descripcion
ORDER BY clientes_distintos DESC;
```

###### *5.*

```sql

SELECT zona,
       tipo_proveedor,
       total_ventas
FROM (
    SELECT dz.nombre AS zona,
           tp.descripcion AS tipo_proveedor,
           COUNT(v.id) AS total_ventas,
           ROW_NUMBER() OVER (PARTITION BY dz.nombre ORDER BY COUNT(v.id) DESC) AS rn
    FROM venta v
    JOIN proveedor p ON v.proveedor_id = p.id
    JOIN tipo_proveedor tp ON p.tipo_id = tp.id
    JOIN cliente c ON v.cliente_id = c.id
    JOIN domicilio d ON c.domicilio_id = d.id
    JOIN domicilio_zona dz ON d.zona_id = dz.id
    GROUP BY dz.nombre, tp.descripcion
) sub
WHERE rn <= 3
ORDER BY zona, total_ventas DESC;

```

###### *6.*

```sql
SELECT p.nombre AS proveedor,
       dz.nombre AS zona,
       v.fecha_hora,
       v.descuento_promocion
FROM venta v
JOIN proveedor p ON v.proveedor_id = p.id
JOIN cliente c ON v.cliente_id = c.id
JOIN domicilio d ON c.domicilio_id = d.id
JOIN domicilio_zona dz ON d.zona_id = dz.id
WHERE v.descuento_promocion > 5000
  AND CAST(v.fecha_hora AS TIME) BETWEEN '18:00:00' AND '22:00:00'
ORDER BY v.fecha_hora DESC;
EN '18:00:00' AND '22:00:00'
ORDER BY v.fecha_hora DESC;
```



## ✅ **3**) Modelo Dimensional Conceptual

## ❄️ Modelo Dimensional Copo de Nieve (Snowflake Schema)

##### Se empleo el **modelo copo de nieve** buscando **normalizar parcialmente las dimensiones**, separando jerarquías o atributos repetidos en subtablas relacionadas.

**_Logrando así mejorar consistencia de datos, reducir redundancia y priorizar **estructuración y mantenibilidad** ._**

#### 🔁 Hecho principal: Venta

Medidas:

- monto_origen
- propina
- costo_servicio
- descuento_promocion
- monto_total
- cantidad_items (nuevo, útil para ticket promedio)
  🔹 Grano:Una venta individual (por pedido realizado)

#### Dimensiones y subdimensiones:

🕒 Tiempo

- Tiempo: dim_tiempo (ID, Fecha, Día, Mes, Año, Trimestre, Semana del año, Día de semana, Festivo (S/N), Día laborable (S/N), Turno (mañana/tarde/noche))

Cliente ➡️ Con jerarquías geográficas y demográficas

- `dim_cliente`: ID, Nombre completo, Sexo, Fecha nacimiento, ID_zona, ID_segmento
- dim_zona:ID_zona, Nombre zona, ID_ciudad
- dim_ciudad: ID_ciudad, Nombre ciudad, ID_region
- dim_region: ID_region, Nombre región, País
- dim_segmento:ID_segmento, Descripción (e.g., Frecuente, Ocasional, VIP), Criterio segmentación

Proveedor ➡️ Con tipo y categoría

- dim_proveedor: ID, Nombre proveedor, ID_tipo, ID_categoria, ID_zona
- dim_tipo_proveedor:ID_tipo, Descripción (e.g., Restaurante, Tienda)
- dim_categoria_proveedor: ID_categoria, Descripción (e.g., Comida rápida, Gourmet)

🚗 Repartidor

- dim_repartidor:ID, Nombre, Sexo, Edad, ID_tipo_contrato, ID_zona
- dim_tipo_contrato: ID_tipo_contrato, Descripción (Fijo, Freelancer, Tercerizado)
  💳 Tipo de Pago
- dim_tipo_pago: ID, Descripción (Tarjeta, Efectivo, etc.), Plataforma (Visa, MasterCard, etc.), Tipo de dispositivo usado

#### 🧾 **Nueva dimensión : `Promoción`**

- dim_promocion: ID_promocion, Nombre, Tipo (Descuento %, cupón), Fecha inicio/fin, Canal, Campaña asociada

#### Consideración:

- Se consideró eliminar Zona (está normalizada dentro de las dimensiones Cliente, Proveedor y Repartidor a través de jerarquías).

#### **Esquema relacional**

    [dim_tiempo]
                            	   |
                              	   v
                         [HECHO_VENTA]
                       /      			|
    			/       			|
    v        		v          v
          [dim_cliente] [dim_proveedor] [dim_repartidor]
         		     |                   |              |
           [dim_zona]         [dim_tipo]   [dim_tipo_contrato]
      			     |                   |
           [dim_ciudad]     [dim_categoria]
              		     |                   |
          [dim_region]      [dim_promocion]
              		     |
         [dim_tipo_pago]

| Aspecto                             | Enfoque Copo de Nieve                                             |
| ----------------------------------- | ----------------------------------------------------------------- |
| **Escalabilidad**             | Soporta crecimiento de información estructurada y detallada.     |
| **Mantenibilidad**            | Cambios en atributos afectan solo una tabla relacionada.          |
| **Análisis jerárquico**     | Posibilidad de análisis por Ciudad, Región, Segmento, etc.      |
| **Segmentación de clientes** | Factible por edad, sexo, zona, segmento de consumo.               |
| **Costos operativos**         | Análisis de contratos de repartidores, categorías de proveedor. |
| **Promociones**               | Permite evaluar efectividad por canal, tipo, campaña.            |

## 🚀 Recomendaciones Futuras

1. **Agregar tabla de hechos adicional para devoluciones o reclamos** (`hecho_reclamo`).
2. **Agregar hechos derivados** como:
   * `hecho_calidad_servicio` (basado en encuestas o valoraciones).
3. **Modelar ciclo de vida del cliente** si hay registro histórico.
4. **Incorporar canal de venta** (App, Web, Llamada), si aplica.
5. **Registrar geolocalización** para análisis espacial (heatmaps, zonas calientes).

## ✅ 4) Granularidad del modelo

La granularidad está dada por HECHO_VENTA contando así con ventas individuales realizada por un cliente a un proveedor, en un momento determinado, con un repartidor asignado, a través de un tipo de pago específico.
