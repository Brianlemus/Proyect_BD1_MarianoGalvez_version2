-- ------------ 1. Actualizar stock tras un préstamo:

-- Después de realizar un préstamo, se debe decrementar el stock del ejemplar 

DELIMITER //
CREATE TRIGGER actualizarStockProducto
AFTER INSERT ON detalle_movimiento
FOR EACH ROW
BEGIN
	
	DECLARE id_inventario_movimiento INT;
	DECLARE id_biblioteca INT;
	DECLARE total_stock INT;
	
	-- Obtiene el id_inventario y idbiblioteca del movimiento
	SELECT m.idbiblioteca, bl.id_inventario INTO id_biblioteca, id_inventario_movimiento	
	FROM movimientos_prestamo m
	INNER JOIN bibliotecas bl ON bl.idbiblioteca=m.idbiblioteca
	 WHERE m.id_movimiento=NEW.id_movimiento;
	
	-- Verifica que haya disponibilidad en la biblioteca y ejemplar solicitado.
	SELECT SUM(stock) AS stock
	FROM inventario_detalle id
	WHERE id.id_inventario = id_inventario_movimiento AND id.idejemplar = NEW.idejemplar
	INTO total_stock;
	
	-- Comprueba si el movimiento tiene id_inventario y si es un tipo de movimiento válido (2: prestamo)
	IF id_inventario_movimiento IS NOT NULL AND NEW.idtipo_movimiento = 2 THEN
		
		-- Comprueba si hay suficiente stock para la cantidad deseada.
		IF total_stock >= NEW.cantidad THEN
			-- Actualiza el stock del inventario.
			UPDATE inventario_detalle id
			SET id.stock = id.stock - NEW.cantidad
			WHERE id.id_inventario = id_inventario_movimiento AND id.idejemplar = NEW.idejemplar;
		
		END IF;
	END IF;
END //
DELIMITER ;

-- para invocar el triger tenemos que insertar un detalle en movimiento y asi descontara del inventario de la biblioteca con el idejemplar
INSERT INTO detalle_movimiento (fecha_ingreso, fecha_vencimiento, id_movimiento, idejemplar, idtipo_movimiento, idestado_movimiento, cantidad) VALUES
(NOW(), NOW(), 28, 1, 2, 2, 1);


-- eliminar el trigger:
DROP TRIGGER actualizarStockProducto;

-- --------------2. Actualizar stock tras una devolución:

-- Al devolver un ejemplar, se debe incrementar el stock del mismo.

DELIMITER //
CREATE TRIGGER actualizarStockejemplardevolucion
AFTER INSERT ON detalle_movimiento
FOR EACH ROW
BEGIN
	
	DECLARE id_inventario_movimiento INT;
	DECLARE id_biblioteca INT;
	DECLARE total_stock INT;
	
	-- Obtiene el id_inventario y idbiblioteca del movimiento
	SELECT m.idbiblioteca, bl.id_inventario INTO id_biblioteca, id_inventario_movimiento	
	FROM movimientos_prestamo m
	INNER JOIN bibliotecas bl ON bl.idbiblioteca=m.idbiblioteca
	 WHERE m.id_movimiento=NEW.id_movimiento;
	
	-- Verifica que haya disponibilidad en la biblioteca y ejemplar solicitado.
	SELECT SUM(stock) AS stock
	FROM inventario_detalle id
	WHERE id.id_inventario = id_inventario_movimiento AND id.idejemplar = NEW.idejemplar
	INTO total_stock;
	
	-- Comprueba si el movimiento tiene id_inventario y si es un tipo de movimiento válido (3: Devolución)
	IF id_inventario_movimiento IS NOT NULL AND NEW.idtipo_movimiento = 3 THEN
		
			-- Actualiza el stock del inventario.
			UPDATE inventario_detalle id
			SET id.stock = id.stock + NEW.cantidad
			WHERE id.id_inventario = id_inventario_movimiento AND id.idejemplar = NEW.idejemplar;
		
	END IF;
END //
DELIMITER ;


INSERT INTO detalle_movimiento (fecha_ingreso, fecha_vencimiento, id_movimiento, idejemplar, idtipo_movimiento, idestado_movimiento, cantidad) VALUES
(NOW(), NOW(), 28, 1, 3, 3, 1);


