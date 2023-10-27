--  crear base de datos para proyecto
create database ProyectoFinalBD;

-- Tabla de categorias
CREATE TABLE categorias (
    idcategoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre_categoria VARCHAR(100) NOT NULL,
    estado_categoria VARCHAR(100) NOT NULL
);

CREATE TABLE registro_editoriales (
    id_editorial INT AUTO_INCREMENT PRIMARY KEY,
    nombre_editorial VARCHAR(100) NOT NULL,
    estado_editorial VARCHAR(100) NOT NULL
);

CREATE TABLE registro_autores (
    id_autor INT AUTO_INCREMENT PRIMARY KEY,
    nombre_autor VARCHAR(100) NOT NULL,
    estado_autor VARCHAR(100) NOT NULL
);

CREATE TABLE registro_ejemplares (
    idejemplar INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    id_autor INT NOT NULL,
    fecha_lanzamiento DATE,
    id_editorial INT,
    idcategoria INT,
    fecha_registro DATE,
    estado VARCHAR(100),
    FOREIGN KEY (id_autor) REFERENCES registro_autores(id_autor) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_editorial) REFERENCES registro_editoriales(id_editorial) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (idcategoria) REFERENCES categorias(idcategoria) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE inventarios (
    id_inventarios INT AUTO_INCREMENT PRIMARY KEY,
    nombre_inventarios VARCHAR(100) NOT NULL
);

CREATE TABLE detalle_inventario (
    id_registro INT AUTO_INCREMENT PRIMARY KEY,
    id_inventarios INT NOT NULL,
    idejemplar INT NOT NULL,
    stock INT NOT NULL,
    stock_reserva INT NOT NULL,
    FOREIGN KEY (id_inventarios) REFERENCES inventarios(id_inventarios) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (idejemplar) REFERENCES registro_ejemplares(idejemplar) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE campus_universidades (
    idcampus_universidades INT AUTO_INCREMENT PRIMARY KEY,
    nombre_campus_universidades VARCHAR(100) NOT NULL,
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

CREATE TABLE registro_horarios (
    id_horario INT AUTO_INCREMENT PRIMARY KEY,
    hora_apertura TIME NOT NULL,
    hora_cierre TIME NOT NULL,
    estado_horario VARCHAR(45) NOT NULL
);

CREATE TABLE registro_bibliotecas (
    idbiblioteca INT AUTO_INCREMENT PRIMARY KEY,
    nombre_biblioteca VARCHAR(100) NOT NULL,
    estado_biblioteca VARCHAR(100) NOT NULL,
    fecha_creacion DATE NOT NULL,
    id_inventarios INT NOT NULL,
    idcampus_universidades INT NOT NULL,
    ubicacion_biblioteca VARCHAR(100) NOT NULL,
    id_encargado INT NOT NULL,
    id_horario INT NOT NULL,
    UNIQUE KEY (id_inventarios),
    FOREIGN KEY (id_inventarios) REFERENCES inventarios(id_inventarios) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (idcampus_universidades) REFERENCES campus_universidades(idcampus_universidades) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_encargado) REFERENCES encargados(id_encargado) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_horario) REFERENCES registro_horarios(id_horario) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE carreras_disponibles (
    id_carrera INT AUTO_INCREMENT PRIMARY KEY,
    nombre_carrera VARCHAR(100) NOT NULL,
    estado_carrera VARCHAR(100) NOT NULL
);

CREATE TABLE registro_estudiantes (
    id_estudiante INT AUTO_INCREMENT PRIMARY KEY,
    nombre_estudiante VARCHAR(100) NOT NULL,
    carnet VARCHAR(100) NOT NULL,
    ciclo VARCHAR(45) NOT NULL,
    fecha_ingreso DATE NOT NULL,
    estado_estudiante VARCHAR(45) NOT NULL,
    id_carrera INT NOT NULL,
    idcampus_universidades INT NOT NULL,
    FOREIGN KEY (idcampus_universidades) REFERENCES campus_universidades(idcampus_universidades) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_carrera) REFERENCES carreras_disponibles(id_carrera) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE estado_mov (
    idestado_movimiento INT AUTO_INCREMENT PRIMARY KEY,
    descripcion_estado VARCHAR(45)
);

CREATE TABLE movimientos (
    id_movimiento INT AUTO_INCREMENT PRIMARY KEY,
    idbiblioteca INT NOT NULL,
    id_estudiante INT NOT NULL,
    fecha_movimiento DATE NOT NULL,
    idestado_movimiento INT NOT NULL,
    FOREIGN KEY (idestado_movimiento) REFERENCES estado_mov(idestado_movimiento) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (idbiblioteca) REFERENCES registro_bibliotecas(idbiblioteca) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_estudiante) REFERENCES registro_estudiantes(id_estudiante) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE tipo_movimiento(
    idtipo_movimiento INT AUTO_INCREMENT PRIMARY KEY,
    descripcion VARCHAR(100) NOT NULL,
    estado_movimiento VARCHAR(45) NOT NULL
);

CREATE TABLE movimiento_detalle (
    idmovimiento_detalle INT AUTO_INCREMENT PRIMARY KEY,
    fecha_ingreso DATE NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    id_movimiento INT NOT NULL,
    idejemplar INT NOT NULL,
    idtipo_movimiento INT NOT NULL,
    idestado_movimiento INT NOT NULL,
    cantidad INT NOT NULL,
    FOREIGN KEY (id_movimiento) REFERENCES movimientos(id_movimiento) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (idejemplar) REFERENCES registro_ejemplares(idejemplar) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (idtipo_movimiento) REFERENCES tipo_movimiento(idtipo_movimiento) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (idestado_movimiento) REFERENCES estado_mov(idestado_movimiento) ON DELETE CASCADE ON UPDATE CASCADE
);