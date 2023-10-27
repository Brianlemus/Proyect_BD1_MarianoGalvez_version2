--  crear base de datos para proyecto
create database proyectBD1;

-- Tabla de catalago
CREATE TABLE catalago (
    idcategoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre_categoria VARCHAR(100) NOT NULL,
    estado_categoria VARCHAR(100) NOT NULL
);

CREATE TABLE editoriales (
    id_editorial INT AUTO_INCREMENT PRIMARY KEY,
    nombre_editorial VARCHAR(100) NOT NULL,
    estado_editorial VARCHAR(100) NOT NULL
);

CREATE TABLE autores (
    id_autor INT AUTO_INCREMENT PRIMARY KEY,
    nombre_autor VARCHAR(100) NOT NULL,
    estado_autor VARCHAR(100) NOT NULL
);

CREATE TABLE ejemplares (
    idejemplar INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    id_autor INT NOT NULL,
    fecha_lanzamiento DATE,
    id_editorial INT,
    idcategoria INT,
    fecha_registro DATE,
    estado VARCHAR(100),
    FOREIGN KEY (id_autor) REFERENCES autores(id_autor) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_editorial) REFERENCES editoriales(id_editorial) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (idcategoria) REFERENCES catalago(idcategoria) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE inventario (
    id_inventario INT AUTO_INCREMENT PRIMARY KEY,
    nombre_inventario VARCHAR(100) NOT NULL
);

CREATE TABLE inventario_detalle (
    id_registro INT AUTO_INCREMENT PRIMARY KEY,
    id_inventario INT NOT NULL,
    idejemplar INT NOT NULL,
    stock INT NOT NULL,
    stock_reserva INT NOT NULL,
    FOREIGN KEY (id_inventario) REFERENCES inventario(id_inventario) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (idejemplar) REFERENCES ejemplares(idejemplar) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE campus (
    idcampus INT AUTO_INCREMENT PRIMARY KEY,
    nombre_campus VARCHAR(100) NOT NULL,
    estado VARCHAR(100) NOT NULL,
    ubicacion VARCHAR(100) NOT NULL,
    fecha_creacion DATE NOT NULL
);

CREATE TABLE encargados (
    id_encargado INT AUTO_INCREMENT PRIMARY KEY,
    nombre_encargado VARCHAR(100) NOT NULL,
    apellido_encargado VARCHAR(100) NOT NULL,
    estado_encargado VARCHAR(100) NOT NULL
);

CREATE TABLE horarios (
    id_horario INT AUTO_INCREMENT PRIMARY KEY,
    hora_apertura TIME NOT NULL,
    hora_cierre TIME NOT NULL,
    estado_horario VARCHAR(45) NOT NULL
);

CREATE TABLE bibliotecas (
    idbiblioteca INT AUTO_INCREMENT PRIMARY KEY,
    nombre_biblioteca VARCHAR(100) NOT NULL,
    estado_biblioteca VARCHAR(100) NOT NULL,
    fecha_creacion DATE NOT NULL,
    id_inventario INT NOT NULL,
    idcampus INT NOT NULL,
    ubicacion_biblioteca VARCHAR(100) NOT NULL,
    id_encargado INT NOT NULL,
    id_horario INT NOT NULL,
    UNIQUE KEY (id_inventario),
    FOREIGN KEY (id_inventario) REFERENCES inventario(id_inventario) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (idcampus) REFERENCES campus(idcampus) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_encargado) REFERENCES encargados(id_encargado) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_horario) REFERENCES horarios(id_horario) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE carrera_universitaria (
    id_carrera INT AUTO_INCREMENT PRIMARY KEY,
    nombre_carrera VARCHAR(100) NOT NULL,
    estado_carrera VARCHAR(100) NOT NULL
);

CREATE TABLE estudiantes (
    id_estudiante INT AUTO_INCREMENT PRIMARY KEY,
    nombre_estudiante VARCHAR(100) NOT NULL,
    carnet VARCHAR(100) NOT NULL,
    ciclo VARCHAR(45) NOT NULL,
    fecha_ingreso DATE NOT NULL,
    estado_estudiante VARCHAR(45) NOT NULL,
    id_carrera INT NOT NULL,
    idcampus INT NOT NULL,
    FOREIGN KEY (idcampus) REFERENCES campus(idcampus) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_carrera) REFERENCES carrera_universitaria(id_carrera) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE estado_movimientos (
    idestado_movimiento INT AUTO_INCREMENT PRIMARY KEY,
    descripcion_estado VARCHAR(45)
);

CREATE TABLE movimientos_prestamo (
    id_movimiento INT AUTO_INCREMENT PRIMARY KEY,
    idbiblioteca INT NOT NULL,
    id_estudiante INT NOT NULL,
    fecha_movimiento DATE NOT NULL,
    idestado_movimiento INT NOT NULL,
    FOREIGN KEY (idestado_movimiento) REFERENCES estado_movimientos(idestado_movimiento) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (idbiblioteca) REFERENCES bibliotecas(idbiblioteca) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_estudiante) REFERENCES estudiantes(id_estudiante) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE tipo_movimiento(
    idtipo_movimiento INT AUTO_INCREMENT PRIMARY KEY,
    descripcion VARCHAR(100) NOT NULL,
    estado_movimiento VARCHAR(45) NOT NULL
);

CREATE TABLE detalle_movimiento (
    iddetalle_movimiento INT AUTO_INCREMENT PRIMARY KEY,
    fecha_ingreso DATE NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    id_movimiento INT NOT NULL,
    idejemplar INT NOT NULL,
    idtipo_movimiento INT NOT NULL,
    idestado_movimiento INT NOT NULL,
    cantidad INT NOT NULL,
    FOREIGN KEY (id_movimiento) REFERENCES movimientos_prestamo(id_movimiento) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (idejemplar) REFERENCES ejemplares(idejemplar) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (idtipo_movimiento) REFERENCES tipo_movimiento(idtipo_movimiento) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (idestado_movimiento) REFERENCES estado_movimientos(idestado_movimiento) ON DELETE CASCADE ON UPDATE CASCADE
);