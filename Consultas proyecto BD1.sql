-- ----------------- Consulta de Ejemplares Disponibles en una Biblioteca Específica -----------------
SELECT bl.idbiblioteca, bl.nombre_biblioteca, id.id_inventario, id.idejemplar, e.nombre, id.stock 
FROM bibliotecas bl, inventario i, inventario_detalle id, ejemplares e
where bl.id_inventario=i.id_inventario and id.id_inventario=i.id_inventario and e.idejemplar=id.idejemplar
and bl.idbiblioteca=1;

-- --------- Ejemplares Más Solicitados en el Último Mes
SELECT dm.idejemplar
        , (SELECT nombre FROM ejemplares jj WHERE jj.idejemplar=dm.idejemplar) AS nombre
        , SUM(dm.cantidad) AS cantidad 
FROM movimientos_prestamo mp
INNER JOIN detalle_movimiento dm
    ON mp.id_movimiento = dm.id_movimiento
WHERE dm.idestado_movimiento = 2
GROUP BY dm.idejemplar
ORDER BY SUM(dm.cantidad) DESC;

-- -------------- Estudiantes con Préstamos Vencidos
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

-- -------------- Ejemplares Disponibles de un Autor Específico
SELECT id.id_inventario, ii.nombre_inventario, id.idejemplar, ej.nombre, SUM(id.stock) AS stock
FROM inventario_detalle id
INNER JOIN ejemplares ej ON id.idejemplar = ej.idejemplar
INNER JOIN inventario ii ON ii.id_inventario = id.id_inventario
WHERE ej.id_autor = 1
GROUP BY id.id_inventario, id.idejemplar, ej.nombre, ii.nombre_inventario
HAVING SUM(id.stock) > 0;

-- ------------- Total, de Préstamos por Biblioteca en un Rango de Fechas
SELECT mp.idbiblioteca
,bl.nombre_biblioteca
, sum(dm.cantidad) AS cantidad
FROM movimientos_prestamo mp
INNER JOIN detalle_movimiento dm
	ON mp.id_movimiento=dm.id_movimiento
INNER JOIN bibliotecas AS bl 
	ON bl.idbiblioteca=mp.idbiblioteca
WHERE dm.fecha_ingreso BETWEEN '20231020' AND '20231026'
	AND dm.idtipo_movimiento=2 -- tipo que indica que es prestamo
GROUP BY mp.idbiblioteca;

-- ------------- Reservas Activas de un Estudiante
SELECT mp.idbiblioteca
,mp.id_estudiante
,ee.nombre_estudiante
,bl.nombre_biblioteca
, sum(dm.cantidad) AS cantidad
FROM movimientos_prestamo mp
INNER JOIN detalle_movimiento dm
	ON mp.id_movimiento=dm.id_movimiento
INNER JOIN bibliotecas AS bl 
	ON bl.idbiblioteca=mp.idbiblioteca
INNER JOIN estudiantes AS ee
	ON ee.id_estudiante=mp.id_estudiante
WHERE  dm.idtipo_movimiento=1 -- tipo que indica que es Reserva
	AND mp.id_estudiante=5 
	AND mp.idestado_movimiento=2 -- estado solicitado
GROUP BY mp.idbiblioteca, id_estudiante;

-- ------- Ejemplares que Deben ser Repuestos o Adquiridos Nuevamente (Stock 0)
SELECT id.idejemplar, ej.nombre, id.stock 
FROM inventario_detalle id, ejemplares ej
WHERE id.stock=0 AND id.idejemplar=ej.idejemplar

-- Préstamos Realizados por un Estudiante Específico
SELECT mp.id_movimiento
			,mp.idbiblioteca
			,mp.id_estudiante
			,ee.nombre_estudiante
			,bl.nombre_biblioteca
			, sum(dm.cantidad) AS cantidad
FROM movimientos_prestamo mp
INNER JOIN detalle_movimiento dm
	ON mp.id_movimiento=dm.id_movimiento
INNER JOIN bibliotecas AS bl 
	ON bl.idbiblioteca=mp.idbiblioteca
INNER JOIN estudiantes AS ee
	ON ee.id_estudiante=mp.id_estudiante
WHERE  dm.idtipo_movimiento=2 -- tipo que indica que es Reserva
	AND mp.id_estudiante=5 
	AND mp.idestado_movimiento=2 -- estado solicitado
GROUP BY mp.id_movimiento, mp.idbiblioteca, id_estudiante;

-- ------------ Bibliotecas con Más Préstamos Activos
SELECT mp.idbiblioteca, bl.nombre_biblioteca, SUM(dm.cantidad) AS cantidad
FROM movimientos_prestamo mp
INNER JOIN detalle_movimiento dm ON mp.id_movimiento = dm.id_movimiento
INNER JOIN bibliotecas AS bl ON bl.idbiblioteca = mp.idbiblioteca
WHERE dm.idtipo_movimiento = 2 -- tipo que indica que es prestamo
GROUP BY mp.idbiblioteca
HAVING SUM(dm.cantidad) = (SELECT MAX(total_cantidad) FROM (SELECT SUM(d.cantidad) AS total_cantidad
                                                              FROM movimientos_prestamo m
                                                              INNER JOIN detalle_movimiento d ON m.id_movimiento = d.id_movimiento
                                                              WHERE d.idtipo_movimiento = 2
                                                              GROUP BY m.idbiblioteca) AS subquery);

-- ------------ Estudiantes que han Reservado un Ejemplar Específico
SELECT mp.id_estudiante
            , ee.nombre_estudiante
            , dm.idejemplar
            , ej.nombre
            , sum(dm.cantidad) AS cantidad
            , dm.idtipo_movimiento 
FROM movimientos_prestamo mp, detalle_movimiento dm, estudiantes ee, ejemplares ej
WHERE  mp.id_movimiento=dm.id_movimiento 
	AND ee.id_estudiante=mp.id_estudiante 
		AND ej.idejemplar=dm.idejemplar 
			and dm.idtipo_movimiento=1 -- tipo de movimiento reserva
				GROUP BY mp.id_estudiante, dm.idejemplar