-- -------------------- Vistas -----------------------------------

-- Vista que muestra todos los préstamos que no han sido devueltos.
CREATE VIEW Prestamos_Activos AS
    SELECT mp.id_movimiento
                , (SELECT nombre_biblioteca FROM bibliotecas AS bl WHERE bl.idbiblioteca=mp.idbiblioteca) AS nombre_biblioteca
                , es.nombre_estudiante
                , dm.fecha_ingreso
                , dm.fecha_vencimiento 
                , (SELECT nombre FROM ejemplares j WHERE j.idejemplar=dm.idejemplar) AS ejemplar
                , tp.descripcion AS nombre_movimiento
                ,(SELECT descripcion_estado FROM estado_movimientos ee WHERE ee.idestado_movimiento = dm.idestado_movimiento) AS estado_movimiento
                , dm.cantidad
    FROM movimientos_prestamo mp
    INNER JOIN detalle_movimiento AS dm
        ON mp.id_movimiento = dm.id_movimiento
    INNER JOIN tipo_movimiento tp 
        ON tp.idtipo_movimiento = dm.idtipo_movimiento
    INNER JOIN estudiantes es 
        ON es.id_estudiante=mp.id_estudiante
    WHERE cast(dm.fecha_vencimiento AS DATE) < cast(NOW() AS DATE) 
        AND dm.idestado_movimiento=2;

-- invocar la vista
SELECT * FROM Prestamos_Activos;

-- eliminar la vista
DROP VIEW Prestamos_Activos;


-- Vista para identificar rápidamente qué ejemplares necesitan ser reabastecidos.
CREATE VIEW ejemplares_sin_stock AS
    SELECT id.id_inventario
    , id.idejemplar
    , e.nombre
    , (SELECT nombre_autor FROM autores a WHERE a.id_autor=e.id_autor) AS nombre_autor
    , (SELECT nombre_editorial FROM editoriales ed WHERE ed.id_editorial = e.id_editorial) AS nombre_editorial
    , (SELECT nombre_categoria FROM catalago cc WHERE cc.idcategoria = e.idcategoria) AS nombre_categoria
    , e.estado
    , id.stock
    , id.stock_reserva
    , (id.stock + id.stock_reserva) AS cantidad_total
    FROM inventario_detalle id
    INNER JOIN ejemplares e
        ON id.idejemplar=e.idejemplar
    WHERE (id.stock + id.stock_reserva) <= 10;

-- invocar la vista
SELECT * FROM ejemplares_sin_stock;

-- eliminar la vista
DROP VIEW ejemplares_sin_stock;
