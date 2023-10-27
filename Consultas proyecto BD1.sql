-- ----------------- Consulta de registro_ejemplares Disponibles en una Biblioteca Específica -----------------
SELECT bl.idbiblioteca, bl.nombre_biblioteca, id.id_inventarios, id.idejemplar, e.nombre, id.stock 
FROM registro_bibliotecas bl, inventarios i, detalle_inventario id, registro_ejemplares e
where bl.id_inventarios=i.id_inventarios and id.id_inventarios=i.id_inventarios and e.idejemplar=id.idejemplar
and bl.idbiblioteca=1;

-- --------- registro_ejemplares Más Solicitados en el Último Mes
SELECT dm.idejemplar
        , (SELECT nombre FROM registro_ejemplares jj WHERE jj.idejemplar=dm.idejemplar) AS nombre
        , SUM(dm.cantidad) AS cantidad 
FROM movimientos mp
INNER JOIN movimiento_detalle dm
    ON mp.id_movimiento = dm.id_movimiento
WHERE dm.idestado_movimiento = 2
GROUP BY dm.idejemplar
ORDER BY SUM(dm.cantidad) DESC;

-- -------------- registro_estudiantes con Préstamos Vencidos
SELECT mp.id_movimiento
                , (SELECT nombre_biblioteca FROM registro_bibliotecas AS bl WHERE bl.idbiblioteca=mp.idbiblioteca) AS nombre_biblioteca
                , es.nombre_estudiante
                , dm.fecha_ingreso
                , dm.fecha_vencimiento 
                , (SELECT nombre FROM registro_ejemplares j WHERE j.idejemplar=dm.idejemplar) AS ejemplar
                , tp.descripcion AS nombre_movimiento
                ,(SELECT descripcion_estado FROM estado_mov ee WHERE ee.idestado_movimiento = dm.idestado_movimiento) AS estado_movimiento
                , dm.cantidad
    FROM movimientos mp
    INNER JOIN movimiento_detalle AS dm
        ON mp.id_movimiento = dm.id_movimiento
    INNER JOIN tipo_movimiento tp 
        ON tp.idtipo_movimiento = dm.idtipo_movimiento
    INNER JOIN registro_estudiantes es 
        ON es.id_estudiante=mp.id_estudiante
    WHERE cast(dm.fecha_vencimiento AS DATE) < cast(NOW() AS DATE) 
        AND dm.idestado_movimiento=2;

-- -------------- registro_ejemplares Disponibles de un Autor Específico
SELECT id.id_inventarios, ii.nombre_inventarios, id.idejemplar, ej.nombre, SUM(id.stock) AS stock
FROM detalle_inventario id
INNER JOIN registro_ejemplares ej ON id.idejemplar = ej.idejemplar
INNER JOIN inventarios ii ON ii.id_inventarios = id.id_inventarios
WHERE ej.id_autor = 1
GROUP BY id.id_inventarios, id.idejemplar, ej.nombre, ii.nombre_inventarios
HAVING SUM(id.stock) > 0;

-- ------------- Total, de Préstamos por Biblioteca en un Rango de Fechas
SELECT mp.idbiblioteca
,bl.nombre_biblioteca
, sum(dm.cantidad) AS cantidad
FROM movimientos mp
INNER JOIN movimiento_detalle dm
	ON mp.id_movimiento=dm.id_movimiento
INNER JOIN registro_bibliotecas AS bl 
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
FROM movimientos mp
INNER JOIN movimiento_detalle dm
	ON mp.id_movimiento=dm.id_movimiento
INNER JOIN registro_bibliotecas AS bl 
	ON bl.idbiblioteca=mp.idbiblioteca
INNER JOIN registro_estudiantes AS ee
	ON ee.id_estudiante=mp.id_estudiante
WHERE  dm.idtipo_movimiento=1 -- tipo que indica que es Reserva
	AND mp.id_estudiante=5 
	AND mp.idestado_movimiento=2 -- estado solicitado
GROUP BY mp.idbiblioteca, id_estudiante;

-- ------- registro_ejemplares que Deben ser Repuestos o Adquiridos Nuevamente (Stock 0)
SELECT id.idejemplar, ej.nombre, id.stock 
FROM detalle_inventario id, registro_ejemplares ej
WHERE id.stock=0 AND id.idejemplar=ej.idejemplar

-- Préstamos Realizados por un Estudiante Específico
SELECT mp.id_movimiento
			,mp.idbiblioteca
			,mp.id_estudiante
			,ee.nombre_estudiante
			,bl.nombre_biblioteca
			, sum(dm.cantidad) AS cantidad
FROM movimientos mp
INNER JOIN movimiento_detalle dm
	ON mp.id_movimiento=dm.id_movimiento
INNER JOIN registro_bibliotecas AS bl 
	ON bl.idbiblioteca=mp.idbiblioteca
INNER JOIN registro_estudiantes AS ee
	ON ee.id_estudiante=mp.id_estudiante
WHERE  dm.idtipo_movimiento=2 -- tipo que indica que es Reserva
	AND mp.id_estudiante=5 
	AND mp.idestado_movimiento=2 -- estado solicitado
GROUP BY mp.id_movimiento, mp.idbiblioteca, id_estudiante;

-- ------------ registro_bibliotecas con Más Préstamos Activos
SELECT mp.idbiblioteca, bl.nombre_biblioteca, SUM(dm.cantidad) AS cantidad
FROM movimientos mp
INNER JOIN movimiento_detalle dm ON mp.id_movimiento = dm.id_movimiento
INNER JOIN registro_bibliotecas AS bl ON bl.idbiblioteca = mp.idbiblioteca
WHERE dm.idtipo_movimiento = 2 -- tipo que indica que es prestamo
GROUP BY mp.idbiblioteca
HAVING SUM(dm.cantidad) = (SELECT MAX(total_cantidad) FROM (SELECT SUM(d.cantidad) AS total_cantidad
                                                              FROM movimientos m
                                                              INNER JOIN movimiento_detalle d ON m.id_movimiento = d.id_movimiento
                                                              WHERE d.idtipo_movimiento = 2
                                                              GROUP BY m.idbiblioteca) AS subquery);

-- ------------ registro_estudiantes que han Reservado un Ejemplar Específico
SELECT mp.id_estudiante
            , ee.nombre_estudiante
            , dm.idejemplar
            , ej.nombre
            , sum(dm.cantidad) AS cantidad
            , dm.idtipo_movimiento 
FROM movimientos mp, movimiento_detalle dm, registro_estudiantes ee, registro_ejemplares ej
WHERE  mp.id_movimiento=dm.id_movimiento 
	AND ee.id_estudiante=mp.id_estudiante 
		AND ej.idejemplar=dm.idejemplar 
			and dm.idtipo_movimiento=1 -- tipo de movimiento reserva
				GROUP BY mp.id_estudiante, dm.idejemplar