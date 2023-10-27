-- ----------------------------1. Préstamos Vencidos de un Estudiante:
DELIMITER $$
CREATE PROCEDURE prestamos_vencidos(IN estudiante INT)
BEGIN
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
        AND dm.idestado_movimiento=2 -- significa prestamo
      		AND mp.id_estudiante=estudiante; -- id estudiante
END $$
DELIMITER ;

-- para invocar el procedimiento
CALL prestamos_vencidos(1);

-- eliminar el procedimiento
DROP PROCEDURE prestamos_vencidos;


-- ----------------- 2. Reservar Ejemplar
-- verifico que si haya disponibilidad en la bilbiote y ejemplar solicitado..!
DELIMITER $$
CREATE PROCEDURE ejemplar_reservado(IN p_estudiante INT, IN p_biblioteca INT, IN p_ejemplar INT, IN p_fecha_vencimiento DATE, IN p_cantidad INT)
	BEGIN
	
		DECLARE id_movimiento_creado INT;
		DECLARE estudiante_activo_count INT;
		DECLARE total_stock INT;
	
	
		-- Verifica que haya disponibilidad en la biblioteca y ejemplar solicitado.
		 SELECT SUM(stock) AS stock
		FROM detalle_inventario id
		INNER JOIN registro_bibliotecas bl
		    ON id.id_inventarios = bl.id_inventarios
		WHERE bl.idbiblioteca = p_biblioteca AND id.idejemplar = p_ejemplar
		INTO total_stock;
			
		-- veritifico que el estudiante esta activo
		SELECT COUNT(id_estudiante) INTO estudiante_activo_count FROM registro_estudiantes es 
		WHERE es.id_estudiante=p_estudiante 
			AND es.estado_estudiante='Activo';
			
			 -- Comprueba si el estudiante está activo.
	    IF estudiante_activo_count > 0 THEN
	        -- Comprueba si hay suficiente stock para la cantidad deseada.
	        IF total_stock >= p_cantidad THEN
	        
	            -- Inserta encabezado (estado 2 es "Solicitado").
	            INSERT INTO movimientos (idbiblioteca, id_estudiante, fecha_movimiento, idestado_movimiento) VALUES
	                (p_biblioteca, p_estudiante, NOW(), 2);
	
	            -- Obtiene el valor del Primary Key generado automáticamente.
	            SET id_movimiento_creado = LAST_INSERT_ID();
	
	            -- Inserta detalle.
	            INSERT INTO movimiento_detalle (fecha_ingreso, fecha_vencimiento, id_movimiento, idejemplar, idtipo_movimiento, idestado_movimiento, cantidad) VALUES
    				(NOW(), STR_TO_DATE(p_fecha_vencimiento, '%Y-%m-%d'), id_movimiento_creado, p_ejemplar, 2, 2, p_cantidad);
				
					-- Envía un mensaje de éxito
	            SIGNAL SQLSTATE '45001'
	            SET MESSAGE_TEXT = 'Movimiento en reserva registrado. Informar al estudiante';

	        ELSE
	            -- No hay suficiente stock para la cantidad deseada, retorna un mensaje de error.
	            SIGNAL SQLSTATE '45000'
	            SET MESSAGE_TEXT = 'No hay suficiente stock para la cantidad deseada.';
	        END IF;
	    ELSE
	        -- El estudiante no está activo, retorna un mensaje de error.
	        SIGNAL SQLSTATE '45000'
	        SET MESSAGE_TEXT = 'El estudiante no está activo.';
	    END IF;
	END $$
DELIMITER ;

-- para invocar el procedimiento
-- Id_estudiante, idbliblioteca, idejemplar, fechavencimiento, cantidad
CALL ejemplar_reservado(2, 1, 1, '20231027', 2);

-- eliminar el procedimiento
DROP PROCEDURE ejemplar_reservado;
