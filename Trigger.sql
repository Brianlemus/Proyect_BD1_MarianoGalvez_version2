-- ------------ 1. Actualizar stock tras un préstamo:

-- Después de realizar un préstamo, se debe decrementar el stock del ejemplar 

DELIMITER //
CREATE TRIGGER prestamosstrock
AFTER INSERT ON movimiento_detalle
FOR EACH ROW
BEGIN
	
	DECLARE id_inventarios_movimiento INT;
	DECLARE id_biblioteca INT;
	DECLARE total_stock INT;
	
	-- Obtiene el id_inventarios y idbiblioteca del movimiento
	SELECT m.idbiblioteca, bl.id_inventarios INTO id_biblioteca, id_inventarios_movimiento	
	FROM movimientos m
	INNER JOIN registro_bibliotecas bl ON bl.idbiblioteca=m.idbiblioteca
	 WHERE m.id_movimiento=NEW.id_movimiento;
	
	-- Verifica que haya disponibilidad en la biblioteca y ejemplar solicitado.
	SELECT SUM(stock) AS stock
	FROM detalle_inventario id
	WHERE id.id_inventarios = id_inventarios_movimiento AND id.idejemplar = NEW.idejemplar
	INTO total_stock;
	
	-- Comprueba si el movimiento tiene id_inventarios y si es un tipo de movimiento válido (2: prestamo)
	IF id_inventarios_movimiento IS NOT NULL AND NEW.idtipo_movimiento = 2 THEN
		
		-- Comprueba si hay suficiente stock para la cantidad deseada.
		IF total_stock >= NEW.cantidad THEN
			-- Actualiza el stock del inventarios.
			UPDATE detalle_inventario id
			SET id.stock = id.stock - NEW.cantidad
			WHERE id.id_inventarios = id_inventarios_movimiento AND id.idejemplar = NEW.idejemplar;
		
		END IF;
	END IF;
END //
DELIMITER ;

-- para invocar el triger tenemos que insertar un detalle en movimiento y asi descontara del inventarios de la biblioteca con el idejemplar
INSERT INTO movimiento_detalle (fecha_ingreso, fecha_vencimiento, id_movimiento, idejemplar, idtipo_movimiento, idestado_movimiento, cantidad) VALUES
(NOW(), NOW(), 28, 1, 2, 2, 1);


-- eliminar el trigger:
DROP TRIGGER prestamosstrock;

-- --------------2. Actualizar stock tras una devolución:

-- Al devolver un ejemplar, se debe incrementar el stock del mismo.

DELIMITER //
CREATE TRIGGER devolucionstock
AFTER INSERT ON movimiento_detalle
FOR EACH ROW
BEGIN
	
	DECLARE id_inventarios_movimiento INT;
	DECLARE id_biblioteca INT;
	DECLARE total_stock INT;
	
	-- Obtiene el id_inventarios y idbiblioteca del movimiento
	SELECT m.idbiblioteca, bl.id_inventarios INTO id_biblioteca, id_inventarios_movimiento	
	FROM movimientos m
	INNER JOIN registro_bibliotecas bl ON bl.idbiblioteca=m.idbiblioteca
	 WHERE m.id_movimiento=NEW.id_movimiento;
	
	-- Verifica que haya disponibilidad en la biblioteca y ejemplar solicitado.
	SELECT SUM(stock) AS stock
	FROM detalle_inventario id
	WHERE id.id_inventarios = id_inventarios_movimiento AND id.idejemplar = NEW.idejemplar
	INTO total_stock;
	
	-- Comprueba si el movimiento tiene id_inventarios y si es un tipo de movimiento válido (3: Devolución)
	IF id_inventarios_movimiento IS NOT NULL AND NEW.idtipo_movimiento = 3 THEN
		
			-- Actualiza el stock del inventarios.
			UPDATE detalle_inventario id
			SET id.stock = id.stock + NEW.cantidad
			WHERE id.id_inventarios = id_inventarios_movimiento AND id.idejemplar = NEW.idejemplar;
		
	END IF;
END //
DELIMITER ;


INSERT INTO movimiento_detalle (fecha_ingreso, fecha_vencimiento, id_movimiento, idejemplar, idtipo_movimiento, idestado_movimiento, cantidad) VALUES
(NOW(), NOW(), 28, 1, 3, 3, 1);

DROP TRIGGER devolucionstock;


